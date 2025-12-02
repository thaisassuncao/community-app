# frozen_string_literal: true

# Performance Optimization: Strategic composite indexes for common query patterns
# Why: These indexes optimize the most frequent and expensive queries in the API:
#
# 1. [community_id, parent_message_id] - Supports fetching top-level messages per community
#    Used by: GET /api/v1/communities/:id/messages/top (engagement scoring query)
#
# 2. [user_ip] - Single-column index for IP-based grouping
#    Used by: GET /api/v1/analytics/suspicious_ips (fraud detection)
#
# 3. [user_ip, user_id] - Composite index for counting distinct users per IP
#    Used by: GET /api/v1/analytics/suspicious_ips (COUNT DISTINCT user_id GROUP BY user_ip)
#
# 4. [message_id, reaction_type] - Supports reaction count aggregation
#    Used by: POST /api/v1/reactions response (GROUP BY reaction_type counts)
#
# Without these indexes, the analytics and engagement queries would require full table scans,
# degrading performance significantly as the database grows beyond ~10k messages.
class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :messages, %i[community_id parent_message_id], if_not_exists: true
    add_index :messages, :user_ip, if_not_exists: true
    add_index :messages, %i[user_ip user_id], if_not_exists: true

    add_index :reactions, %i[message_id reaction_type], if_not_exists: true
  end
end
