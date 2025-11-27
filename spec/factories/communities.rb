# frozen_string_literal: true

FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "Community #{n}" }
    description { "A great community for developers" }
  end
end
