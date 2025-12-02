# frozen_string_literal: true

module Api
  module V1
    class AnalyticsController < ApplicationController
      def suspicious_ips
        min_users = params[:min_users]&.to_i || 3

        suspicious_data = fetch_suspicious_ips(min_users)
        usernames_by_ip = fetch_usernames_by_ip(suspicious_data.pluck(:user_ip))

        suspicious_ips = build_suspicious_ips_response(suspicious_data, usernames_by_ip)
        render json: { suspicious_ips: suspicious_ips }, status: :ok
      end

      private

      # Business Rule: IP-based fraud/abuse detection
      # Why: Multiple distinct user accounts posting from the same IP address is a strong
      # indicator of coordinated abuse, bot networks, or sockpuppet accounts
      # Legitimate scenarios (shared office WiFi, VPN) exist, but they're rare enough that
      # this is still a valuable moderation signal. Default threshold of 3 users balances
      # false positives (catching real abuse) vs false negatives (flagging legitimate use)
      # Moderators can adjust min_users parameter based on their community's characteristics
      def fetch_suspicious_ips(min_users)
        Message
          .select("user_ip as ip, COUNT(DISTINCT user_id) as user_count")
          .group(:user_ip)
          .having("COUNT(DISTINCT user_id) >= ?", min_users)
          .order(Arel.sql("COUNT(DISTINCT user_id) DESC"))
      end

      def fetch_usernames_by_ip(suspicious_ips_array)
        Message
          .joins(:user)
          .where(user_ip: suspicious_ips_array)
          .select("messages.user_ip, users.username")
          .distinct
          .group_by(&:user_ip)
          .transform_values { |messages| messages.map(&:username).uniq }
      end

      def build_suspicious_ips_response(suspicious_data, usernames_by_ip)
        suspicious_data.map do |data|
          {
            ip: data.ip,
            user_count: data.user_count,
            usernames: usernames_by_ip[data.ip] || []
          }
        end
      end
    end
  end
end
