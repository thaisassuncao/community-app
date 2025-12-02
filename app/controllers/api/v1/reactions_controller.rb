# frozen_string_literal: true

module Api
  module V1
    class ReactionsController < ApplicationController
      def create
        message = Message.find(reaction_params[:message_id])

        reaction = Reaction.new(
          message_id: reaction_params[:message_id],
          user_id: reaction_params[:user_id],
          reaction_type: reaction_params[:reaction_type]
        )

        if reaction.save
          render json: reaction_response(message), status: :created
        else
          render json: { errors: reaction.errors.full_messages }, status: :unprocessable_content
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ["Message not found"] }, status: :not_found
      end

      private

      def reaction_params
        params.require(:reaction).permit(:message_id, :user_id, :reaction_type)
      end

      # API Design: Return aggregated reaction counts for the entire message
      # Why: Clients need the full state of all reactions to maintain accurate UI.
      # If we only returned the newly created reaction, the client would need to make
      # a separate GET request to fetch updated counts, or maintain complex client-side
      # state merging. This approach prevents race conditions where multiple users react
      # simultaneously - each gets the current totals immediately after their action.
      def reaction_response(message)
        reaction_counts = message.reactions
                                 .group(:reaction_type)
                                 .count

        {
          message_id: message.id,
          reactions: {
            like: reaction_counts["like"] || 0,
            love: reaction_counts["love"] || 0,
            insightful: reaction_counts["insightful"] || 0
          }
        }
      end
    end
  end
end
