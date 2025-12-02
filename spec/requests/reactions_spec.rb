# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reactions" do
  describe "POST /messages/:message_id/reactions" do
    let(:message) { create(:message) }
    let(:user) { create(:user) }

    let(:valid_params) do
      {
        reaction: {
          user_id: user.id,
          reaction_type: "like"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new reaction" do
        expect do
          post message_reactions_path(message), params: valid_params,
                                                headers: { "Accept" => "text/vnd.turbo-stream.html" }
        end.to change(Reaction, :count).by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "with duplicate reaction" do
      before { create(:reaction, message: message, user: user, reaction_type: "like") }

      it "does not create duplicate reaction" do
        expect do
          post message_reactions_path(message), params: valid_params,
                                                headers: { "Accept" => "text/vnd.turbo-stream.html" }
        end.not_to change(Reaction, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns JSON error when format is JSON" do
        expect do
          post message_reactions_path(message), params: valid_params,
                                                headers: { "Accept" => "application/json" }
        end.not_to change(Reaction, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.media_type).to eq("application/json")
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end
    end

    context "with JSON format" do
      it "returns JSON success response" do
        expect do
          post message_reactions_path(message), params: valid_params,
                                                headers: { "Accept" => "application/json" }
        end.to change(Reaction, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")
        json_response = response.parsed_body
        expect(json_response["success"]).to be true
      end
    end
  end
end
