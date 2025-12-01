# frozen_string_literal: true

class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :messages, %i[community_id parent_message_id], if_not_exists: true
    add_index :messages, :user_ip, if_not_exists: true
    add_index :messages, %i[user_ip user_id], if_not_exists: true

    add_index :reactions, %i[message_id reaction_type], if_not_exists: true
  end
end
