require "spec_helper"

module CFoundry
  module V2
    describe Space do
      let(:client) { build(:client) }
      let(:space) { build(:space, :client => client) }

      it_behaves_like "a summarizeable model" do
        subject { space }
        let(:summary_attributes) { {:name => "fizzbuzz"} }
      end

      describe "#add_manager_by_username" do
        let(:user) { build(:user) }
        let(:status) { 201 }

        let(:add_manager_space_response) do
          <<-json
{
  "metadata": {
    "guid": "4351f97b-3485-4738-821b-5bf77bed44eb",
    "url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb",
    "created_at": "2015-11-30T23:38:28Z",
    "updated_at": null
  },
  "entity": {
    "name": "name-98",
    "organization_guid": "a488910d-2d69-46a2-bf6e-319248e03705",
    "space_quota_definition_guid": null,
    "allow_ssh": true,
    "organization_url": "/v2/organizations/a488910d-2d69-46a2-bf6e-319248e03705",
    "developers_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/developers",
    "managers_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/managers",
    "auditors_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/auditors",
    "apps_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/apps",
    "routes_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/routes",
    "domains_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/domains",
    "service_instances_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/service_instances",
    "app_events_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/app_events",
    "events_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/events",
    "security_groups_url": "/v2/spaces/4351f97b-3485-4738-821b-5bf77bed44eb/security_groups"
  }
}
json
        end

        before do
          allow(user).to receive(:username).and_return("user_1")
          stub_request(:put, "http://api.example.com/v2/spaces/#{space.guid}/managers").to_return(status: status, body: add_manager_space_response)
        end

        it "adds the given user to SpaceManager in the space" do
          space.add_manager_by_username("user_1")
          expect(WebMock).to have_requested(:put, "http://api.example.com/v2/spaces/#{space.guid}/managers")
        end
      end

      describe "#add_auditor_by_username" do
        let(:user) { build(:user) }
        let(:status) { 201 }

        let(:add_auditor_space_response) do
          <<-json
{
  "metadata": {
    "guid": "873193ee-878c-436f-80bd-10d68927937d",
    "url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d",
    "created_at": "2015-11-30T23:38:28Z",
    "updated_at": null
  },
  "entity": {
    "name": "name-101",
    "organization_guid": "5fddaf61-092d-4b33-9490-8350963db89e",
    "space_quota_definition_guid": null,
    "allow_ssh": true,
    "organization_url": "/v2/organizations/5fddaf61-092d-4b33-9490-8350963db89e",
    "developers_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/developers",
    "managers_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/managers",
    "auditors_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/auditors",
    "apps_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/apps",
    "routes_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/routes",
    "domains_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/domains",
    "service_instances_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/service_instances",
    "app_events_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/app_events",
    "events_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/events",
    "security_groups_url": "/v2/spaces/873193ee-878c-436f-80bd-10d68927937d/security_groups"
  }
}
json
        end

        before do
          allow(user).to receive(:username).and_return("user_1")
          stub_request(:put, "http://api.example.com/v2/spaces/#{space.guid}/auditors").to_return(status: status, body: add_auditor_space_response)
        end

        it "adds the given user to SpaceAuditor in the space" do
          space.add_auditor_by_username("user_1")
          expect(WebMock).to have_requested(:put, "http://api.example.com/v2/spaces/#{space.guid}/auditors")
        end
      end

      describe "#add_developer_by_username" do
        let(:user) { build(:user) }
        let(:status) { 201 }

        let(:add_developer_space_response) do
          <<-json
{
  "metadata": {
    "guid": "b6d11f17-1cea-4c00-a951-fef3223b8c84",
    "url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84",
    "created_at": "2015-11-30T23:38:27Z",
    "updated_at": null
  },
  "entity": {
    "name": "name-58",
    "organization_guid": "b13bbebe-427e-424d-8820-2937f7e218d5",
    "space_quota_definition_guid": null,
    "allow_ssh": true,
    "organization_url": "/v2/organizations/b13bbebe-427e-424d-8820-2937f7e218d5",
    "developers_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/developers",
    "managers_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/managers",
    "auditors_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/auditors",
    "apps_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/apps",
    "routes_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/routes",
    "domains_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/domains",
    "service_instances_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/service_instances",
    "app_events_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/app_events",
    "events_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/events",
    "security_groups_url": "/v2/spaces/b6d11f17-1cea-4c00-a951-fef3223b8c84/security_groups"
  }
}
json
        end

        before do
          allow(user).to receive(:username).and_return("user_1")
          stub_request(:put, "http://api.example.com/v2/spaces/#{space.guid}/developers").to_return(status: status, body: add_developer_space_response)
        end

        it "adds the given user to SpaceDeveloper in the space" do
          space.add_developer_by_username("user_1")
          expect(WebMock).to have_requested(:put, "http://api.example.com/v2/spaces/#{space.guid}/developers")
        end
      end
    end
  end
end
