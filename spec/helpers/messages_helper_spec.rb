# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessagesHelper do
  describe "#sentiment_class" do
    it "returns neutral class for nil score" do
      expect(helper.sentiment_class(nil)).to eq("sentiment-neutral-card")
    end

    it "returns neutral class for zero score" do
      expect(helper.sentiment_class(0.0)).to eq("sentiment-neutral-card")
    end

    it "returns positive class for positive score" do
      expect(helper.sentiment_class(0.5)).to eq("sentiment-positive-card")
    end

    it "returns negative class for negative score" do
      expect(helper.sentiment_class(-0.5)).to eq("sentiment-negative-card")
    end
  end
end
