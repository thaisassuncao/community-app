# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Communities" do
  describe "GET /api/v1/communities" do
    it "returns all communities" do
      create(:community, name: "Rails Community", description: "Ruby on Rails developers")
      create(:community, name: "Python Community", description: "Python developers")

      get "/api/v1/communities"

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body

      expect(json_response.size).to eq(2)
      expect(json_response.first).to have_key("id")
      expect(json_response.first).to have_key("name")
      expect(json_response.first).to have_key("description")
    end

    it "returns empty array when no communities exist" do
      get "/api/v1/communities"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end

  describe "POST /api/v1/communities" do
    let(:valid_params) do
      {
        community: {
          name: "New Community",
          description: "A brand new community"
        }
      }
    end

    let(:invalid_params) do
      {
        community: {
          name: "",
          description: "Missing name"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new community" do
        expect do
          post "/api/v1/communities", params: valid_params, as: :json
        end.to change(Community, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["community"]["name"]).to eq("New Community")
        expect(json_response["community"]["description"]).to eq("A brand new community")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        expect do
          post "/api/v1/communities", params: invalid_params, as: :json
        end.not_to change(Community, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end
    end

    context "with duplicate name" do
      before do
        create(:community, name: "Existing Community")
      end

      it "returns unprocessable entity" do
        params = {
          community: {
            name: "Existing Community",
            description: "Duplicate name"
          }
        }

        post "/api/v1/communities", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to include("Name has already been taken")
      end
    end
  end

  describe "GET /api/v1/communities/:id/messages/top" do
    let(:community) { create(:community) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    context "when fetching top messages by engagement" do
      let!(:message1) { create(:message, community: community, user: user1) }
      let!(:message2) { create(:message, community: community, user: user2) }
      let!(:message3) { create(:message, community: community, user: user1) }

      before do
        # Message 1: 3 reactions (3 * 1.5 = 4.5) + 2 replies (2 * 1.0 = 2.0) = 6.5
        create_list(:reaction, 3, message: message1)
        create_list(:message, 2, community: community, parent_message: message1)

        # Message 2: 5 reactions (5 * 1.5 = 7.5) + 1 reply (1 * 1.0 = 1.0) = 8.5
        create_list(:reaction, 5, message: message2)
        create(:message, community: community, parent_message: message2)

        # Message 3: 1 reaction (1 * 1.5 = 1.5) + 0 replies = 1.5
        create(:reaction, message: message3)
      end

      it "returns messages ordered by engagement score" do
        get "/api/v1/communities/#{community.id}/messages/top"

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        messages = json_response["messages"]

        expect(messages.size).to eq(3)
        expect(messages[0]["id"]).to eq(message2.id)
        expect(messages[0]["engagement_score"]).to eq(8.5)
        expect(messages[1]["id"]).to eq(message1.id)
        expect(messages[1]["engagement_score"]).to eq(6.5)
        expect(messages[2]["id"]).to eq(message3.id)
        expect(messages[2]["engagement_score"]).to eq(1.5)
      end

      it "includes user information" do
        get "/api/v1/communities/#{community.id}/messages/top"

        json_response = response.parsed_body
        first_message = json_response["messages"].first

        expect(first_message["user"]["id"]).to eq(user2.id)
        expect(first_message["user"]["username"]).to eq(user2.username)
      end

      it "includes reaction and reply counts" do
        get "/api/v1/communities/#{community.id}/messages/top"

        json_response = response.parsed_body
        first_message = json_response["messages"].first

        expect(first_message["reaction_count"]).to eq(5)
        expect(first_message["reply_count"]).to eq(1)
      end
    end

    context "with limit parameter" do
      before do
        create_list(:message, 15, community: community)
      end

      it "respects custom limit" do
        get "/api/v1/communities/#{community.id}/messages/top", params: { limit: 5 }

        json_response = response.parsed_body
        expect(json_response["messages"].size).to eq(5)
      end

      it "defaults to 10 messages" do
        get "/api/v1/communities/#{community.id}/messages/top"

        json_response = response.parsed_body
        expect(json_response["messages"].size).to eq(10)
      end

      it "caps at maximum of 50 messages" do
        get "/api/v1/communities/#{community.id}/messages/top", params: { limit: 100 }

        json_response = response.parsed_body
        expect(json_response["messages"].size).to eq(15) # Only 15 messages exist
      end
    end

    context "when community does not exist" do
      it "returns not found" do
        get "/api/v1/communities/999999/messages/top"

        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response["errors"]).to include("Community not found")
      end
    end

    context "when community has no messages" do
      let(:empty_community) { create(:community) }

      it "returns empty array" do
        get "/api/v1/communities/#{empty_community.id}/messages/top"

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["messages"]).to be_empty
      end
    end
  end
end
