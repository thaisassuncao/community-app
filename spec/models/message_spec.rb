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
    it "calculates positive sentiment" do
      message = build(:message, content: "Este produto é ótimo!")
      message.save
      expect(message.ai_sentiment_score).to eq(1.0)
    end

    it "calculates negative sentiment" do
      message = build(:message, content: "Isso é ruim")
      message.save
      expect(message.ai_sentiment_score).to eq(-1.0)
    end

    it "calculates neutral sentiment" do
      message = build(:message, content: "Vou almoçar arroz e feijão")
      message.save
      expect(message.ai_sentiment_score).to eq(0.0)
    end
  end
end
