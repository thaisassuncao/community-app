# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user
  belongs_to :community

  # Architecture Decision: Self-referential association for threaded conversations
  # Why: Allows nested replies within messages, creating a tree structure for discussions.
  # The optional: true allows top-level messages (no parent).
  # The dependent: :destroy ensures data integrity - deleting a message deletes all replies.
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :destroy,
                     inverse_of: :parent_message
  has_many :reactions, dependent: :destroy

  validates :content, presence: true
  validates :user_ip, presence: true

  # Business Rule: Calculate sentiment at write time, not read time
  # Why: This improves query performance for analytics endpoints and ensures
  # sentiment scores are immutable. If we calculated on-read, the score could
  # change if the word list is updated, making historical analysis inconsistent.
  before_save :calculate_sentiment_score

  def calculate_sentiment_score
    self.ai_sentiment_score = SentimentAnalyzer.analyze(content)
  end
end
