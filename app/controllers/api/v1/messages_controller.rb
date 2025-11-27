# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ApplicationController
      def create
        user = find_or_create_user
        message = build_message(user)

        # TODO: Implement AI sentiment score calculation
        # message.ai_sentiment_score = message.calculate_sentiment_score

        if message.save
          render json: message_response(message), status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def find_or_create_user
        User.find_or_create_by(username: message_params[:username])
      end

      def build_message(user)
        Message.new(
          user: user,
          community_id: message_params[:community_id],
          content: message_params[:content],
          user_ip: message_params[:user_ip],
          parent_message_id: message_params[:parent_message_id]
        )
      end

      def message_params
        params.require(:message).permit(:username, :community_id, :content, :user_ip, :parent_message_id)
      end

      def message_response(message)
        {
          id: message.id,
          content: message.content,
          user: {
            id: message.user.id,
            username: message.user.username
          },
          community_id: message.community_id,
          parent_message_id: message.parent_message_id,
          ai_sentiment_score: message.ai_sentiment_score, # TODO: Will be calculated with AI integration
          created_at: message.created_at.iso8601
        }
      end
    end
  end
end
