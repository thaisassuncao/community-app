# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Community App API V1",
        version: "v1",
        description: "API for managing communities, messages and reactions with sentiment analysis"
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        },
        {
          url: "https://{defaultHost}",
          description: "Production server",
          variables: {
            defaultHost: {
              default: "www.example.com"
            }
          }
        }
      ],
      components: {
        schemas: {
          community: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id name]
          },
          message: {
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
              community_id: { type: :integer },
              parent_message_id: { type: :integer, nullable: true },
              ai_sentiment_score: { type: :number, format: :float },
              created_at: { type: :string, format: "date-time" }
            },
            required: %w[id content user community_id ai_sentiment_score created_at]
          },
          reaction_counts: {
            type: :object,
            properties: {
              like: { type: :integer },
              love: { type: :integer },
              insightful: { type: :integer }
            }
          },
          error: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string }
              }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
