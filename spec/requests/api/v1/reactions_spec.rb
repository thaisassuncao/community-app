# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Reactions" do
  describe "POST /api/v1/reactions" do
    let(:user) { create(:user) }
    let(:community) { create(:community) }
    let(:message) { create(:message, community: community, user: user) }

    let(:valid_params) do
      {
        reaction: {
          message_id: message.id,
          user_id: user.id,
          reaction_type: "like"
        }
      }
    end

    context "when creating a valid reaction" do
      it "creates a new reaction and returns reaction counts" do
        expect do
          post "/api/v1/reactions", params: valid_params
        end.to change(Reaction, :count).by(1)

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["message_id"]).to eq(message.id)
        expect(json_response["reactions"]["like"]).to eq(1)
        expect(json_response["reactions"]["love"]).to eq(0)
        expect(json_response["reactions"]["insightful"]).to eq(0)
      end
    end

    context "when trying to add duplicate reaction" do
      before { create(:reaction, message: message, user: user, reaction_type: "like") }

      it "returns unprocessable entity" do
        post "/api/v1/reactions", params: valid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end
    end

    context "when message does not exist" do
      it "returns not found" do
        invalid_params = valid_params.deep_dup
        invalid_params[:reaction][:message_id] = 999_999

        post "/api/v1/reactions", params: invalid_params

        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response["errors"]).to include("Message not found")
      end
    end

    context "with multiple reactions of different types" do
      before do
        create(:reaction, message: message, user: create(:user), reaction_type: "like")
        create(:reaction, message: message, user: create(:user), reaction_type: "like")
        create(:reaction, message: message, user: create(:user), reaction_type: "love")
      end

      it "returns correct counts for all reaction types" do
        post "/api/v1/reactions", params: valid_params

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["reactions"]["like"]).to eq(3)
        expect(json_response["reactions"]["love"]).to eq(1)
        expect(json_response["reactions"]["insightful"]).to eq(0)
      end
    end

    context "with invalid reaction type" do
      it "returns unprocessable entity" do
        invalid_params = valid_params.deep_dup
        invalid_params[:reaction][:reaction_type] = "invalid_type"

        post "/api/v1/reactions", params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
