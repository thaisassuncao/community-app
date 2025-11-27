# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:community) }
    it { is_expected.to belong_to(:parent_message).optional }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
    it { is_expected.to have_many(:reactions).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:user_ip) }
  end

  describe "#calculate_sentiment_score" do
    it "returns nil as placeholder for AI integration" do
      message = build(:message)
      expect(message.calculate_sentiment_score).to be_nil
    end
  end
end
