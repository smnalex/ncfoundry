require "spec_helper"

module CFoundry
  module V2
    describe Organization do
      let(:client) { build(:client) }
      let(:organization) { build(:organization, :client => client) }

      it_behaves_like "a summarizeable model" do
        subject { organization }
        let(:summary_attributes) { {:name => "fizzbuzz"} }
      end

      it "has quota_definition" do
        quota = build(:quota_definition)
        organization.quota_definition = quota
        expect(organization.quota_definition).to eq(quota)
      end

      it "has billing_enabled" do
        [true, false].each do |v|
          organization.billing_enabled = v
          expect(organization.billing_enabled).to eq(v)
        end
      end

      describe "#delete_user_from_all_roles" do
        let(:user) { build(:user) }
        let(:organization) do
          build(:organization, client: client, users: [user],
            managers: [user], billing_managers: [user], auditors: [user])
        end

        let(:status) { 201 }

        let(:delete_from_org_response) do
          <<-json
{
  "metadata": {
    "guid": "24113d03-204b-4d23-b320-4127ee9c0006",
    "url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006",
    "created_at": "2013-08-17T00:47:03+00:00",
    "updated_at": "2013-08-17T00:47:04+00:00"
  },
  "entity": {
    "name": "dsabeti-the-org",
    "billing_enabled": false,
    "quota_definition_guid": "b72b1acb-ff4f-468d-99c0-05cd91012b62",
    "status": "active",
    "quota_definition_url": "/v2/quota_definitions/b72b1acb-ff4f-468d-99c0-05cd91012b62",
    "spaces_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/spaces",
    "domains_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/domains",
    "users_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/users",
    "managers_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/managers",
    "billing_managers_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/billing_managers",
    "auditors_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/auditors",
    "app_events_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006/app_events"
  }
}
json
        end

        let(:delete_from_space_response) do
          <<-json
{
  "metadata": {
    "guid": "6825e318-7a3f-4d50-a2a9-dd7088c95347",
    "url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347",
    "created_at": "2013-10-18T00:54:34+00:00",
    "updated_at": null
  },
  "entity": {
    "name": "asdf",
    "organization_guid": "24113d03-204b-4d23-b320-4127ee9c0006",
    "organization_url": "/v2/organizations/24113d03-204b-4d23-b320-4127ee9c0006",
    "developers_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/developers",
    "managers_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/managers",
    "auditors_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/auditors",
    "apps_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/apps",
    "domains_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/domains",
    "service_instances_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/service_instances",
    "app_events_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/app_events",
    "events_url": "/v2/spaces/6825e318-7a3f-4d50-a2a9-dd7088c95347/events"
  }
}
          json
        end

        let(:space1) do
          build(:space, organization: organization,
            developers: [user], auditors: [user], managers: [user])
        end

        let(:space2) do
          build(:space, organization: organization,
            developers: [user], auditors: [user], managers: [user])
        end

        before do
          allow(organization).to receive(:spaces).and_return([space1, space2])

          stub_request(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/users/#{user.guid}").to_return(status: status, body: delete_from_org_response)
          stub_request(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/managers/#{user.guid}").to_return(status: status, body: delete_from_org_response)
          stub_request(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/billing_managers/#{user.guid}").to_return(status: status, body: delete_from_org_response)
          stub_request(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/auditors/#{user.guid}").to_return(status: status, body: delete_from_org_response)

          stub_request(:delete, "http://api.example.com/v2/spaces/#{space1.guid}/developers/#{user.guid}").to_return(status: status, body: delete_from_space_response)
          stub_request(:delete, "http://api.example.com/v2/spaces/#{space1.guid}/managers/#{user.guid}").to_return(status: status, body: delete_from_space_response)
          stub_request(:delete, "http://api.example.com/v2/spaces/#{space1.guid}/auditors/#{user.guid}").to_return(status: status, body: delete_from_space_response)

          stub_request(:delete, "http://api.example.com/v2/spaces/#{space2.guid}/developers/#{user.guid}").to_return(status: status, body: delete_from_space_response)
          stub_request(:delete, "http://api.example.com/v2/spaces/#{space2.guid}/managers/#{user.guid}").to_return(status: status, body: delete_from_space_response)
          stub_request(:delete, "http://api.example.com/v2/spaces/#{space2.guid}/auditors/#{user.guid}").to_return(status: status, body: delete_from_space_response)
        end

        it "removes the given user from all roles in the org and all its spaces" do
          organization.delete_user_from_all_roles(user)

          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/users/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/managers/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/billing_managers/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/organizations/#{organization.guid}/auditors/#{user.guid}")

          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/spaces/#{space1.guid}/auditors/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/spaces/#{space1.guid}/managers/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/spaces/#{space1.guid}/developers/#{user.guid}")

          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/spaces/#{space2.guid}/auditors/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/spaces/#{space2.guid}/managers/#{user.guid}")
          expect(WebMock).to have_requested(:delete, "http://api.example.com/v2/spaces/#{space2.guid}/developers/#{user.guid}")
        end
      end

      describe "#add_manager_by_username" do
        let(:user) { build(:user) }
        let(:organization) do
          build(:organization, client: client, users: [],
            managers: [], billing_managers: [], auditors: [])
        end

        let(:status) { 201 }

        let(:add_manager_org_response) do
          <<-json
{
  "metadata": {
    "guid": "8d2238e2-2fb3-4ede-b188-1fd3a533c4b4",
    "url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4",
    "created_at": "2015-11-30T23:38:59Z",
    "updated_at": null
  },
  "entity": {
    "name": "name-2523",
    "billing_enabled": false,
    "quota_definition_guid": "0e36ae22-a752-4e37-9dbf-0bac5c1b93c1",
    "status": "active",
    "quota_definition_url": "/v2/quota_definitions/0e36ae22-a752-4e37-9dbf-0bac5c1b93c1",
    "spaces_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/spaces",
    "domains_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/domains",
    "private_domains_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/private_domains",
    "users_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/users",
    "managers_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/managers",
    "billing_managers_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/billing_managers",
    "auditors_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/auditors",
    "app_events_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/app_events",
    "space_quota_definitions_url": "/v2/organizations/8d2238e2-2fb3-4ede-b188-1fd3a533c4b4/space_quota_definitions"
  }
}
json
        end

        before do
          allow(user).to receive(:username).and_return("user_1")
          stub_request(:put, "http://api.example.com/v2/organizations/#{organization.guid}/managers").to_return(status: status, body: add_manager_org_response)
        end

        it "adds the given user to OrgManager in the org" do
          organization.add_manager_by_username("user_1")
          expect(WebMock).to have_requested(:put, "http://api.example.com/v2/organizations/#{organization.guid}/managers")
        end
      end

      describe "#add_billing_manager_by_username" do
        let(:user) { build(:user) }
        let(:organization) do
          build(:organization, client: client, users: [],
            managers: [], billing_managers: [], auditors: [])
        end

        let(:status) { 201 }

        let(:add_billing_manager_org_response) do
          <<-json
{
  "metadata": {
    "guid": "c8d4f13c-8880-4859-8e03-fc690efd8f48",
    "url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48",
    "created_at": "2015-11-30T23:38:58Z",
    "updated_at": null
  },
  "entity": {
    "name": "name-2470",
    "billing_enabled": false,
    "quota_definition_guid": "4ad7378e-e90a-4714-b906-a451dd0d5507",
    "status": "active",
    "quota_definition_url": "/v2/quota_definitions/4ad7378e-e90a-4714-b906-a451dd0d5507",
    "spaces_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/spaces",
    "domains_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/domains",
    "private_domains_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/private_domains",
    "users_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/users",
    "managers_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/managers",
    "billing_managers_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/billing_managers",
    "auditors_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/auditors",
    "app_events_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/app_events",
    "space_quota_definitions_url": "/v2/organizations/c8d4f13c-8880-4859-8e03-fc690efd8f48/space_quota_definitions"
  }
}
json
        end

        before do
          allow(user).to receive(:username).and_return("user_1")
          stub_request(:put, "http://api.example.com/v2/organizations/#{organization.guid}/billing_managers").to_return(status: status, body: add_billing_manager_org_response)
        end

        it "adds the given user to OrgBillingMnager in the org" do
          organization.add_billing_manager_by_username("user_1")
          expect(WebMock).to have_requested(:put, "http://api.example.com/v2/organizations/#{organization.guid}/billing_managers")
        end
      end

      describe "#add_auditor_by_username" do
        let(:user) { build(:user) }
        let(:organization) do
          build(:organization, client: client, users: [],
            managers: [], billing_managers: [], auditors: [])
        end

        let(:status) { 201 }

        let(:add_auditor_org_response) do
          <<-json
{
  "metadata": {
    "guid": "50dfb04d-cd49-477d-a54c-32e00e180022",
    "url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022",
    "created_at": "2015-11-30T23:38:58Z",
    "updated_at": null
  },
  "entity": {
    "name": "name-2476",
    "billing_enabled": false,
    "quota_definition_guid": "8de0754e-bb1e-4739-be6e-91104bbab281",
    "status": "active",
    "quota_definition_url": "/v2/quota_definitions/8de0754e-bb1e-4739-be6e-91104bbab281",
    "spaces_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/spaces",
    "domains_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/domains",
    "private_domains_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/private_domains",
    "users_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/users",
    "managers_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/managers",
    "billing_managers_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/billing_managers",
    "auditors_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/auditors",
    "app_events_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/app_events",
    "space_quota_definitions_url": "/v2/organizations/50dfb04d-cd49-477d-a54c-32e00e180022/space_quota_definitions"
  }
}
json
        end

        before do
          allow(user).to receive(:username).and_return("user_1")
          stub_request(:put, "http://api.example.com/v2/organizations/#{organization.guid}/auditors").to_return(status: status, body: add_auditor_org_response)
        end

        it "adds the given user to OrgAuditor in the org" do
          organization.add_auditor_by_username("user_1")
          expect(WebMock).to have_requested(:put, "http://api.example.com/v2/organizations/#{organization.guid}/auditors")
        end
      end
    end
  end
end
