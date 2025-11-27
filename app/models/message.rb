# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user
  belongs_to :community
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :destroy,
                     inverse_of: :parent_message
  has_many :reactions, dependent: :destroy

  validates :content, presence: true
  validates :user_ip, presence: true

  # TODO: Implement AI sentiment score calculation
  # This method will be implemented when integrating AI service
  def calculate_sentiment_score
    # Will return a float between -1.0 (negative) and 1.0 (positive)
    nil
  end
end
