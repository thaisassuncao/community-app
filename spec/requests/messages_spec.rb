# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Messages" do
  describe "GET /messages/:id" do
    let(:message) { create(:message) }
    let!(:reply) { create(:message, parent_message: message, community: message.community) }

    it "shows message with replies" do
      get message_path(message)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(message.content)
      expect(response.body).to include(reply.content)
    end
  end

  describe "POST /messages" do
    let(:community) { create(:community) }
    let(:valid_params) do
      {
        message: {
          username: "testuser",
          content: "Test message content",
          community_id: community.id,
          user_ip: "192.168.1.1"
        }
      }
    end

    it "creates a new message" do
      expect do
        post messages_path, params: valid_params
      end.to change(Message, :count).by(1)

      expect(response).to have_http_status(:redirect)
    end

    it "creates a new user if username does not exist" do
      expect do
        post messages_path, params: valid_params
      end.to change(User, :count).by(1)

      expect(User.last.username).to eq("testuser")
    end

    it "uses existing user if username exists" do
      create(:user, username: "testuser")

      expect do
        post messages_path, params: valid_params
      end.not_to change(User, :count)
    end

    context "when creating a reply to a message" do
      let(:parent_message) { create(:message, community: community) }
      let(:reply_params) do
        valid_params.merge(
          message: valid_params[:message].merge(parent_message_id: parent_message.id)
        )
      end

      it "redirects to parent message path" do
        post messages_path, params: reply_params

        expect(response).to redirect_to(message_path(parent_message.id))
      end
    end

    context "when validation fails" do
      let(:invalid_params) do
        {
          message: {
            username: "testuser",
            content: "",
            community_id: community.id,
            user_ip: "192.168.1.1"
          }
        }
      end

      it "redirects with alert" do
        post messages_path, params: invalid_params

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to be_present
      end

      it "renders turbo_stream with errors" do
        post messages_path, params: invalid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "with turbo_stream format" do
      it "renders turbo_stream on success" do
        post messages_path, params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end
end
