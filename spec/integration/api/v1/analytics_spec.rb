# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/analytics" do
  path "/api/v1/analytics/suspicious_ips" do
    get "Suspicious IPs" do
      tags "Analytics"
      description "Identifies IPs used by multiple users (possible account sharing or VPN). By default, returns IPs used by 3 or more users."
      produces "application/json"

      parameter name: :min_users, in: :query, type: :integer, required: false, description: "Minimum number of users to consider IP suspicious (default: 3)"

      response "200", "list of suspicious IPs" do
        schema type: :object,
               properties: {
                 suspicious_ips: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       ip: { type: :string, example: "192.168.1.1", description: "IP address" },
                       user_count: { type: :integer, example: 5, description: "Number of distinct users using this IP" },
                       usernames: {
                         type: :array,
                         items: { type: :string },
                         example: %w[user1 user2 user3],
                         description: "List of usernames using this IP"
                       }
                     },
                     required: %w[ip user_count usernames]
                   }
                 }
               }

        let(:min_users) { 2 }
        let(:community) { create(:community) }
        let(:shared_ip) { "192.168.1.100" }

        let!(:user1) { create(:user, username: "user1") }
        let!(:user2) { create(:user, username: "user2") }
        let!(:user3) { create(:user, username: "user3") }

        let!(:message1) { create(:message, user: user1, community: community, user_ip: shared_ip) }
        let!(:message2) { create(:message, user: user2, community: community, user_ip: shared_ip) }
        let!(:message3) { create(:message, user: user3, community: community, user_ip: shared_ip) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["suspicious_ips"]).to be_an(Array)

          if data["suspicious_ips"].any?
            first_result = data["suspicious_ips"].first
            expect(first_result).to have_key("ip")
            expect(first_result).to have_key("user_count")
            expect(first_result).to have_key("usernames")
            expect(first_result["usernames"]).to be_an(Array)
          end
        end
      end

      response "200", "empty list when no suspicious IPs exist" do
        schema type: :object,
               properties: {
                 suspicious_ips: {
                   type: :array,
                   items: {}
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["suspicious_ips"]).to eq([])
        end
      end
    end
  end
end
