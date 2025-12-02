# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ApplicationController
      def create
        user = find_or_create_user
        message = build_message(user)

        if message.save
          render json: message_response(message), status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      # Business Rule: Pseudo-anonymous user creation
      # Why: This allows posting without pre-registration, lowering the barrier to
      # participation. Users are identified by username only (no email/password).
      # find_or_create_by ensures the same username maps to the same user_id,
      # enabling basic identity tracking for moderation (IP analysis, reaction limits)
      # while maintaining a low-friction experience.
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

      # API Design: Expose AI sentiment score in message response
      # Why: Sentiment analysis is a core feature for moderation and content filtering.
      # By exposing it in the API response, clients can build features like:
      # - Highlighting negative messages for moderator review
      # - Filtering timelines by sentiment (show only positive discussions)
      # - Analytics dashboards showing community health trends
      # The score is calculated at write time (see Message model) for consistency.
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
          ai_sentiment_score: message.ai_sentiment_score,
          created_at: message.created_at.iso8601
        }
      end
    end
  end
end
