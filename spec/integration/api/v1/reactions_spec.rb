# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/reactions" do
  path "/api/v1/reactions" do
    post "Create reaction" do
      tags "Reactions"
      description "Adds a reaction to a message. Prevents duplicate reactions (same user, same message, same type)."
      consumes "application/json"
      produces "application/json"

      parameter name: :reaction, in: :body, schema: {
        type: :object,
        properties: {
          reaction: {
            type: :object,
            properties: {
              user_id: { type: :integer, example: 1, description: "User ID" },
              message_id: { type: :integer, example: 10, description: "Message ID" },
              reaction_type: {
                type: :string,
                enum: %w[like love insightful],
                example: "like",
                description: "Reaction type: like, love or insightful"
              }
            },
            required: %w[user_id message_id reaction_type]
          }
        },
        required: ["reaction"]
      }

      response "201", "reaction created successfully" do
        schema type: :object,
               properties: {
                 message_id: { type: :integer },
                 reactions: { "$ref" => "#/components/schemas/reaction_counts" }
               }

        let(:user) { create(:user) }
        let(:message) { create(:message) }
        let(:reaction) do
          {
            reaction: {
              user_id: user.id,
              message_id: message.id,
              reaction_type: "like"
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["message_id"]).to eq(message.id)
          expect(data["reactions"]).to have_key("like")
        end
      end

      response "422", "duplicate reaction or invalid parameters" do
        schema "$ref" => "#/components/schemas/error"

        let(:user) { create(:user) }
        let(:message) { create(:message) }
        let!(:existing_reaction) { create(:reaction, user: user, message: message, reaction_type: "like") }
        let(:reaction) do
          {
            reaction: {
              user_id: user.id,
              message_id: message.id,
              reaction_type: "like"
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["errors"]).to be_present
        end
      end

      response "404", "message not found" do
        schema "$ref" => "#/components/schemas/error"

        let(:user) { create(:user) }
        let(:reaction) do
          {
            reaction: {
              user_id: user.id,
              message_id: 999_999,
              reaction_type: "like"
            }
          }
        end

        run_test!
      end
    end
  end
end
