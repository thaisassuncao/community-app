# frozen_string_literal: true

# Simple keyword-based sentiment analyzer
# Returns a score between -1.0 (negative) and 1.0 (positive)
class SentimentAnalyzer
  POSITIVE_WORDS = %w[
    ótimo excelente legal bom boa adorei incrível
    ótima maravilhoso fantástico perfeito
    amei gostei bacana show demais
    feliz alegre satisfeito contente
  ].freeze

  NEGATIVE_WORDS = %w[
    ruim péssimo péssima horrível terrível odeio
    detesto mal pior odiei
    triste chato decepcionante frustrante
    insatisfeito descontente
  ].freeze

  def self.analyze(text)
    new(text).analyze
  end

  def initialize(text)
    @text = text.to_s.downcase
  end

  def analyze
    return 0.0 if @text.blank?

    positive = count_words(POSITIVE_WORDS)
    negative = count_words(NEGATIVE_WORDS)
    total = positive + negative

    return 0.0 if total.zero?

    ((positive - negative).to_f / total).round(2)
  end

  private

  # Architecture Decision: Use word boundary matching (\b) instead of partial matching
  # Why: This ensures "bom" (good) matches only as a complete word, not as part of
  # compound words like "bom-dia" or "bomba". This prevents false positives/negatives
  # in Portuguese sentiment analysis where partial matches would skew results.
  # Example: "bombardeio" contains "bom" but has negative sentiment.
  def count_words(word_list)
    word_list.count { |word| @text.match?(/\b#{Regexp.escape(word)}\b/) }
  end
end
