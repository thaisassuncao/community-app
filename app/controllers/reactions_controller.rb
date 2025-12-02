# frozen_string_literal: true

class ReactionsController < ApplicationController
  def create
    @message = Message.find(params[:message_id])
    @reaction = @message.reactions.new(reaction_params)

    if @reaction.save
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { success: true }, status: :ok }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_content }
        format.json do
          render json: { errors: @reaction.errors.full_messages }, status: :unprocessable_content
        end
      end
    end
  end

  private

  def reaction_params
    params.require(:reaction).permit(:user_id, :reaction_type)
  end
end
