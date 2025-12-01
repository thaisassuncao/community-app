# frozen_string_literal: true

require "rails_helper"

RSpec.describe SentimentAnalyzer do
  describe ".analyze" do
    context "with positive content" do
      it "returns positive score for single positive word" do
        expect(described_class.analyze("Este produto é ótimo!")).to eq(1.0)
      end

      it "returns positive score for multiple positive words" do
        expect(described_class.analyze("Adorei! Excelente e maravilhoso")).to eq(1.0)
      end
    end

    context "with negative content" do
      it "returns negative score for single negative word" do
        expect(described_class.analyze("Isso é ruim")).to eq(-1.0)
      end

      it "returns negative score for multiple negative words" do
        expect(described_class.analyze("Péssimo e horrível")).to eq(-1.0)
      end
    end

    context "with mixed content" do
      it "returns balanced score for equal positive and negative words" do
        expect(described_class.analyze("Bom mas ruim")).to eq(0.0)
      end

      it "returns positive score when more positive words" do
        expect(described_class.analyze("Excelente e bom, apesar de um pouco ruim")).to eq(0.33)
      end

      it "returns negative score when more negative words" do
        expect(described_class.analyze("Ruim e péssimo, mas tem algo bom")).to eq(-0.33)
      end
    end

    context "with neutral content" do
      it "returns zero for content without sentiment words" do
        expect(described_class.analyze("Hoje é segunda-feira")).to eq(0.0)
      end

      it "returns zero for empty string" do
        expect(described_class.analyze("")).to eq(0.0)
      end

      it "returns zero for nil" do
        expect(described_class.analyze(nil)).to eq(0.0)
      end
    end

    context "with case variations" do
      it "is case insensitive" do
        expect(described_class.analyze("ÓTIMO")).to eq(1.0)
        expect(described_class.analyze("Ótimo")).to eq(1.0)
        expect(described_class.analyze("ótimo")).to eq(1.0)
      end
    end

    context "with word boundary matching" do
      it "does not match partial words" do
        expect(described_class.analyze("normal")).to eq(0.0)
        expect(described_class.analyze("anormal")).to eq(0.0)
        expect(described_class.analyze("minimal")).to eq(0.0)
      end

      it "matches complete words only" do
        expect(described_class.analyze("Isso está mal")).to eq(-1.0)
        expect(described_class.analyze("Está ruim")).to eq(-1.0)
        expect(described_class.analyze("Está bom")).to eq(1.0)
      end
    end
  end
end
