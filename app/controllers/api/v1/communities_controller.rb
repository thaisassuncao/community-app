# frozen_string_literal: true

module Api
  module V1
    class CommunitiesController < ApplicationController
      def index
        communities = Community.all

        render json: communities.map { |c|
          { id: c.id, name: c.name, description: c.description }
        }, status: :ok
      end

      def create
        community = Community.new(community_params)

        if community.save
          render json: {
            community: { id: community.id, name: community.name, description: community.description }
          }, status: :created
        else
          render json: { errors: community.errors.full_messages }, status: :unprocessable_content
        end
      end

      def top_messages
        community = Community.find(params[:id])
        limit = calculate_limit(params[:limit])
        messages = fetch_top_messages(community, limit)

        render json: { messages: messages.map { |msg| message_response(msg) } }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ["Community not found"] }, status: :not_found
      end

      private

      def community_params
        params.require(:community).permit(:name, :description)
      end

      def calculate_limit(limit_param)
        limit = [limit_param.to_i, 50].min
        limit <= 0 ? 10 : limit
      end

      # Business Rule: Weighted engagement scoring algorithm
      # Why: Reactions are weighted 1.5x higher than replies because emoji reactions
      # require minimal effort (single click) while writing a reply requires thought
      # and composition. This values substantive engagement (replies) as the primary
      # signal, with reactions as a secondary but still meaningful indicator.
      # Formula: (reactions * 1.5) + replies = engagement_score
      def fetch_top_messages(community, limit)
        community.messages
                 .select(
                   "messages.*",
                   "COUNT(DISTINCT reactions.id) as reaction_count",
                   "COUNT(DISTINCT child_messages.id) as reply_count",
                   "((COUNT(DISTINCT reactions.id) * 1.5) + " \
                   "COUNT(DISTINCT child_messages.id)) as engagement_score"
                 )
                 .joins("LEFT JOIN reactions ON reactions.message_id = messages.id")
                 .joins("LEFT JOIN messages AS child_messages ON " \
                        "child_messages.parent_message_id = messages.id")
                 .where(parent_message_id: nil)
                 .group("messages.id")
                 .order(engagement_score: :desc)
                 .limit(limit)
                 .includes(:user)
      end

      def message_response(message)
        {
          id: message.id,
          content: message.content,
          user: {
            id: message.user.id,
            username: message.user.username
          },
          ai_sentiment_score: message.ai_sentiment_score,
          reaction_count: message.reaction_count.to_i,
          reply_count: message.reply_count.to_i,
          engagement_score: message.engagement_score.to_f
        }
      end
    end
  end
end
