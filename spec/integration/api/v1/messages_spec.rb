# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/messages" do
  path "/api/v1/messages" do
    post "Create new message" do
      tags "Messages"
      description "Creates a new message in a community. Performs sentiment analysis automatically."
      consumes "application/json"
      produces "application/json"

      parameter name: :message, in: :body, schema: {
        type: :object,
        properties: {
          message: {
            type: :object,
            properties: {
              username: { type: :string, example: "john_doe", description: "Username (created if doesn't exist)" },
              community_id: { type: :integer, example: 1, description: "Community ID" },
              content: { type: :string, example: "This is a test message", description: "Message content" },
              user_ip: { type: :string, example: "192.168.1.1", description: "User IP address" },
              parent_message_id: { type: :integer, example: 10, nullable: true, description: "Parent message ID (for comments)" }
            },
            required: %w[username community_id content user_ip]
          }
        },
        required: ["message"]
      }

      response "201", "message created successfully" do
        let(:community) { create(:community) }
        let(:message) do
          {
            message: {
              username: "john_doe",
              community_id: community.id,
              content: "Message content",
              user_ip: "192.168.1.1"
            }
          }
        end

        schema type: :object,
               properties: {
                 id: { type: :integer },
                 content: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     username: { type: :string }
                   }
                 },
                 community_id: { type: :integer },
                 parent_message_id: { type: :integer, nullable: true },
                 ai_sentiment_score: { type: :number, format: :float, description: "Sentiment score (-1.0 to 1.0)" },
                 created_at: { type: :string, format: "date-time" }
               },
               required: %w[id content user community_id ai_sentiment_score created_at]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["content"]).to eq("Message content")
          expect(data["user"]["username"]).to eq("john_doe")
        end
      end

      response "422", "invalid parameters" do
        let(:message) do
          {
            message: {
              username: "john_doe",
              community_id: 999_999,
              content: "",
              user_ip: "192.168.1.1"
            }
          }
        end

        schema "$ref" => "#/components/schemas/error"

        run_test!
      end
    end
  end
end
