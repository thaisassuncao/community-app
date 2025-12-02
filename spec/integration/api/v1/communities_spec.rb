# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/communities" do
  path "/api/v1/communities" do
    get "List communities" do
      tags "Communities"
      description "Returns all registered communities"
      produces "application/json"

      response "200", "list of communities" do
        schema type: :array,
               items: { "$ref" => "#/components/schemas/community" }

        let!(:communities) { create_list(:community, 3) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(3)
        end
      end
    end

    post "Create community" do
      tags "Communities"
      description "Creates a new community"
      consumes "application/json"
      produces "application/json"

      parameter name: :community, in: :body, schema: {
        type: :object,
        properties: {
          community: {
            type: :object,
            properties: {
              name: { type: :string, example: "Ruby Brasil", description: "Community name (must be unique)" }
            },
            required: ["name"]
          }
        },
        required: ["community"]
      }

      response "201", "community created successfully" do
        let(:community) do
          {
            community: {
              name: "New Community"
            }
          }
        end

        schema type: :object,
               properties: {
                 community: { "$ref" => "#/components/schemas/community" }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["community"]["name"]).to eq("New Community")
        end
      end

      response "422", "duplicate or invalid name" do
        let!(:existing_community) { create(:community, name: "Existing Community") }
        let(:community) do
          {
            community: {
              name: "Existing Community"
            }
          }
        end

        schema "$ref" => "#/components/schemas/error"

        run_test!
      end
    end
  end

  path "/api/v1/communities/{id}/messages/top" do
    parameter name: :id, in: :path, type: :integer, description: "Community ID"

    get "Top messages by engagement" do
      tags "Communities"
      description "Returns the most engaged messages from a community (based on reactions and replies)"
      produces "application/json"

      parameter name: :limit, in: :query, type: :integer, required: false, description: "Number of messages (default: 10, maximum: 50)"

      response "200", "list of messages ordered by engagement" do
        schema type: :object,
               properties: {
                 messages: {
                   type: :array,
                   items: {
                     type: :object,
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
                       engagement_score: { type: :number, description: "Engagement score (reactions + replies)" },
                       reaction_count: { type: :integer },
                       reply_count: { type: :integer },
                       ai_sentiment_score: { type: :number },
                       created_at: { type: :string, format: "date-time" }
                     }
                   }
                 }
               }

        let(:community) { create(:community) }
        let(:id) { community.id }
        let(:limit) { 5 }
        let!(:message) { create(:message, community: community) }
        let!(:reactions) { create_list(:reaction, 3, message: message) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["messages"]).to be_an(Array)
          expect(data["messages"].first["engagement_score"]).to be_a(Numeric)
        end
      end

      response "404", "community not found" do
        let(:id) { 999_999 }

        schema "$ref" => "#/components/schemas/error"

        run_test!
      end
    end
  end
end
