# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reaction do
  describe "associations" do
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject(:reaction) { build(:reaction) }

    it { is_expected.to validate_presence_of(:reaction_type) }
    it { is_expected.to validate_inclusion_of(:reaction_type).in_array(%w[like love insightful]) }

    it do
      expect(reaction).to validate_uniqueness_of(:message_id)
        .scoped_to(%i[user_id reaction_type])
    end
  end
end
