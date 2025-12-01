# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Analytics" do
  describe "GET /api/v1/analytics/suspicious_ips" do
    let(:community) { create(:community) }

    context "when detecting IPs used by multiple users" do
      let(:user1) { create(:user, username: "user1") }
      let(:user2) { create(:user, username: "user2") }
      let(:user3) { create(:user, username: "user3") }
      let(:user4) { create(:user, username: "user4") }
      let(:user5) { create(:user, username: "user5") }

      before do
        # IP 192.168.1.1 used by 5 users
        create(:message, user: user1, community: community, user_ip: "192.168.1.1")
        create(:message, user: user2, community: community, user_ip: "192.168.1.1")
        create(:message, user: user3, community: community, user_ip: "192.168.1.1")
        create(:message, user: user4, community: community, user_ip: "192.168.1.1")
        create(:message, user: user5, community: community, user_ip: "192.168.1.1")

        # IP 192.168.1.2 used by 3 users
        create(:message, user: user1, community: community, user_ip: "192.168.1.2")
        create(:message, user: user2, community: community, user_ip: "192.168.1.2")
        create(:message, user: user3, community: community, user_ip: "192.168.1.2")

        # IP 192.168.1.3 used by 2 users (not suspicious with default min_users=3)
        create(:message, user: user1, community: community, user_ip: "192.168.1.3")
        create(:message, user: user2, community: community, user_ip: "192.168.1.3")

        # IP 192.168.1.4 used by 1 user (not suspicious)
        create(:message, user: user1, community: community, user_ip: "192.168.1.4")
      end

      it "returns IPs used by at least 3 users by default" do
        get "/api/v1/analytics/suspicious_ips"

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        suspicious_ips = json_response["suspicious_ips"]

        expect(suspicious_ips.size).to eq(2)
        expect(suspicious_ips[0]["ip"]).to eq("192.168.1.1")
        expect(suspicious_ips[0]["user_count"]).to eq(5)
        expect(suspicious_ips[1]["ip"]).to eq("192.168.1.2")
        expect(suspicious_ips[1]["user_count"]).to eq(3)
      end

      it "includes all usernames for each suspicious IP" do
        get "/api/v1/analytics/suspicious_ips"

        json_response = response.parsed_body
        first_ip_data = json_response["suspicious_ips"].first

        expect(first_ip_data["usernames"]).to match_array(%w[user1 user2 user3 user4 user5])
      end

      it "orders by user count descending" do
        get "/api/v1/analytics/suspicious_ips"

        json_response = response.parsed_body
        suspicious_ips = json_response["suspicious_ips"]

        expect(suspicious_ips[0]["user_count"]).to be > suspicious_ips[1]["user_count"]
      end
    end

    context "with custom min_users parameter" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      before do
        create(:message, user: user1, community: community, user_ip: "192.168.1.1")
        create(:message, user: user2, community: community, user_ip: "192.168.1.1")
      end

      it "respects custom min_users threshold" do
        get "/api/v1/analytics/suspicious_ips", params: { min_users: 2 }

        json_response = response.parsed_body
        expect(json_response["suspicious_ips"].size).to eq(1)
        expect(json_response["suspicious_ips"][0]["user_count"]).to eq(2)
      end

      it "returns empty array if threshold is too high" do
        get "/api/v1/analytics/suspicious_ips", params: { min_users: 10 }

        json_response = response.parsed_body
        expect(json_response["suspicious_ips"]).to be_empty
      end
    end

    context "when no suspicious IPs exist" do
      before do
        user = create(:user)
        create(:message, user: user, community: community, user_ip: "192.168.1.1")
        create(:message, user: user, community: community, user_ip: "192.168.1.2")
      end

      it "returns empty array" do
        get "/api/v1/analytics/suspicious_ips"

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response["suspicious_ips"]).to be_empty
      end
    end
  end
end
