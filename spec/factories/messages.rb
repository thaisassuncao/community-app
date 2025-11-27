# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    association :user
    association :community
    content { "This is a sample message content" }
    user_ip { "192.168.1.1" }
    parent_message_id { nil }
    ai_sentiment_score { nil }
  end
end
