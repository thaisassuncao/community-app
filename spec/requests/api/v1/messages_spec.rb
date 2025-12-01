# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Messages" do
  describe "POST /api/v1/messages" do
    let(:community) { create(:community) }
    let(:valid_params) do
      {
        message: {
          username: "john_doe",
          community_id: community.id,
          content: "Conteúdo da mensagem",
          user_ip: "192.168.1.1"
        }
      }
    end

    context "when creating a new message with a new user" do
      it "creates a new user and message" do
        expect do
          post "/api/v1/messages", params: valid_params
        end.to change(User, :count).by(1).and change(Message, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["content"]).to eq("Conteúdo da mensagem")
        expect(json_response["user"]["username"]).to eq("john_doe")
        expect(json_response["community_id"]).to eq(community.id)
        expect(json_response["ai_sentiment_score"]).to eq(0.0)
      end
    end

    context "when creating a message with an existing user" do
      let!(:existing_user) { create(:user, username: "john_doe") }

      it "does not create a new user" do
        expect do
          post "/api/v1/messages", params: valid_params
        end.to change(Message, :count).by(1)
                                      .and not_change(User, :count)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["user"]["id"]).to eq(existing_user.id)
      end
    end

    context "when creating a comment (with parent_message_id)" do
      let(:parent_message) { create(:message, community: community) }
      let(:comment_params) do
        valid_params.merge(
          message: valid_params[:message].merge(parent_message_id: parent_message.id)
        )
      end

      it "creates a message with parent_message_id" do
        post "/api/v1/messages", params: comment_params

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["parent_message_id"]).to eq(parent_message.id)
      end
    end

    context "when validation fails" do
      let(:invalid_params) do
        {
          message: {
            username: "john_doe",
            community_id: community.id,
            content: "",
            user_ip: "192.168.1.1"
          }
        }
      end

      it "returns unprocessable entity status" do
        post "/api/v1/messages", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end
    end

    context "when community does not exist" do
      let(:invalid_community_params) do
        {
          message: {
            username: "john_doe",
            community_id: 999_999,
            content: "Test message",
            user_ip: "192.168.1.1"
          }
        }
      end

      it "returns unprocessable entity status" do
        post "/api/v1/messages", params: invalid_community_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to be_present
      end
    end

    context "when required fields are missing" do
      let(:missing_fields_params) do
        {
          message: {
            username: "john_doe"
          }
        }
      end

      it "returns unprocessable entity status" do
        post "/api/v1/messages", params: missing_fields_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with sentiment analysis" do
      it "calculates positive sentiment score" do
        positive_params = valid_params.deep_dup
        positive_params[:message][:content] = "Este produto é ótimo e excelente!"

        post "/api/v1/messages", params: positive_params

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["ai_sentiment_score"]).to eq(1.0)
      end

      it "calculates negative sentiment score" do
        negative_params = valid_params.deep_dup
        negative_params[:message][:content] = "Isso é ruim e péssimo"

        post "/api/v1/messages", params: negative_params

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["ai_sentiment_score"]).to eq(-1.0)
      end

      it "calculates neutral sentiment score" do
        neutral_params = valid_params.deep_dup
        neutral_params[:message][:content] = "Hoje vou almoçar macarrão"

        post "/api/v1/messages", params: neutral_params

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response["ai_sentiment_score"]).to eq(0.0)
      end
    end
  end
end
