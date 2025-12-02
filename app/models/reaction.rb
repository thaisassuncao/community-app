# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  VALID_TYPES = %w[like love insightful].freeze

  validates :reaction_type, presence: true, inclusion: { in: VALID_TYPES }

  # Business Rule: One reaction per user per type per message
  # Why: Prevents users from spamming the same reaction multiple times.
  # This is enforced at both the application level (validation) and database level
  # (unique composite index in migration) to prevent race conditions.
  # A user can give different reaction types to the same message (like + love),
  # but cannot give the same type twice.
  validates :message_id, uniqueness: { scope: %i[user_id reaction_type] }
end
