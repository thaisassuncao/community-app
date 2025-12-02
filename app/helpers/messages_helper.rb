# frozen_string_literal: true

module MessagesHelper
  def sentiment_class(score)
    return "sentiment-neutral-card" if score.nil? || score.zero?

    score.positive? ? "sentiment-positive-card" : "sentiment-negative-card"
  end
end
