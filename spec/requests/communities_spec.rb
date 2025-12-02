# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Communities" do
  describe "GET /communities" do
    it "lists all communities" do
      create(:community, name: "Rails Community")
      create(:community, name: "JS Community")

      get communities_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Rails Community")
      expect(response.body).to include("JS Community")
    end
  end

  describe "GET /communities/:id" do
    let(:community) { create(:community) }
    let!(:message) { create(:message, community: community) }

    it "shows community timeline" do
      get community_path(community)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(community.name)
      expect(response.body).to include(message.content)
    end

    it "shows only top-level messages" do
      parent_message = create(:message, community: community, content: "This is a parent message")
      create(:message, community: community, parent_message: parent_message,
                       content: "This is a reply message")

      get community_path(community)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("This is a parent message")
      expect(response.body).not_to include("This is a reply message")
    end
  end
end
