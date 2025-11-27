# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  VALID_TYPES = %w[like love insightful].freeze

  validates :reaction_type, presence: true, inclusion: { in: VALID_TYPES }
  validates :message_id, uniqueness: { scope: %i[user_id reaction_type] }
end
