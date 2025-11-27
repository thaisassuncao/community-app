# frozen_string_literal: true

FactoryBot.define do
  factory :reaction do
    association :message
    association :user
    reaction_type { "like" }
  end
end
