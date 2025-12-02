# frozen_string_literal: true

class MessagesController < ApplicationController
  def show
    @message = Message.includes(:user, :reactions, replies: %i[user reactions]).find(params[:id])
    @reply = Message.new
  end

  def create
    @message = Message.new(message_params)
    @message.user = find_or_create_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to redirect_path, notice: "Message created successfully!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("message_form", partial: "form",
                                                                    locals: {
                                                                      message: @message,
                                                                      community: @message.community,
                                                                      parent_message: @message.parent_message
                                                                    })
        end
        format.html { redirect_to redirect_path, alert: @message.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :community_id, :parent_message_id, :user_ip)
  end

  def find_or_create_user
    User.find_or_create_by(username: params[:message][:username])
  end

  def redirect_path
    if @message.parent_message_id
      message_path(@message.parent_message_id)
    else
      community_path(@message.community_id)
    end
  end
end
