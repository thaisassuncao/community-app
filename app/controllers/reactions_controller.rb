# frozen_string_literal: true

class ReactionsController < ApplicationController
  def create
    @message = Message.find(params[:message_id])
    @reaction = build_reaction

    if @reaction.save
      handle_success
    else
      handle_failure
    end
  end

  private

  def build_reaction
    user = find_or_create_user
    @message.reactions.new(user: user, reaction_type: reaction_params[:reaction_type])
  end

  def find_or_create_user
    User.find_or_create_by(id: reaction_params[:user_id]) do |u|
      u.username = "user_#{reaction_params[:user_id]}"
    end
  end

  def handle_success
    respond_to do |format|
      format.turbo_stream
      format.json { render json: { success: true }, status: :ok }
    end
  end

  def handle_failure
    respond_to do |format|
      format.turbo_stream { head :unprocessable_content }
      format.json { render json: { errors: @reaction.errors.full_messages }, status: :unprocessable_content }
    end
  end

  def reaction_params
    params.require(:reaction).permit(:user_id, :reaction_type)
  end
end
