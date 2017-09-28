require "spec_helper"

module CFoundry
  module V2

    # be careful, there is a TestModel in global scope because of the TestModelBuilder
    class TestModel < CFoundry::V2::Model
      attribute :foo, :string
      to_one :domain

      def create_endpoint_name
        :odd_endpoint
      end
    end

    class DefaultTestModel < CFoundry::V2::Model
      attribute :foo, :string
    end

    describe Model do
      let(:client) { build(:client) }
      let(:guid) { "my-object-guid" }
      let(:manifest) { {:metadata => {:guid => "some-guid-1"}, :entity => {}} }
      let(:model) { TestModel.new(guid, client, manifest) }

      describe "create" do
        it "uses #create!" do
          expect(model).to receive(:create!).with({})
          model.create
        end

        it "passes options along to create!" do
          expect(model).to receive(:create!).with(:accepts_incomplete => true)
          model.create(:accepts_incomplete => true)
        end

        context "without errors" do
          it "returns true" do
            expect(model).to receive(:create!).with({})
            expect(model.create).to eq(true)
          end
        end

        context "with errors" do
          before do
            allow(model.class).to receive(:model_name) { ActiveModel::Name.new(model, nil, "abstract_model") }
            allow(model).to receive(:create!) { raise CFoundry::APIError.new("HELP") }
          end

          it "does not raise an exception" do
            expect { model.create }.to_not raise_error
          end

          it "returns false" do
            expect(model.create).to eq(false)
          end

          context "without model-specific errors" do
            it "adds generic base error " do
              model.create
              expect(model.errors.full_messages.first).to match(/cloud controller reported an error/i)
            end
          end

          context "with model-specific errors" do
            it "does not set the generic error on base" do
              model.create
              expect(model.errors.size).to eq(1)
            end
          end
        end
      end

      describe "#create!" do
        before do
          allow(client.base).to receive(:post) {
            {:metadata => {
                :guid => "123",
                :created_at => "2013-06-10 10:41:15 -0700",
                :updated_at => "2015-06-10 10:41:15 -0700"
            }}
          }
          model.foo = "bar"
        end

        context "without options" do
          it "posts to the model's create url with appropriate arguments and empty params hash" do
            expect(client.base).to receive(:post).with("v2", :odd_endpoint,
              :content => :json,
              :accept => :json,
              :payload => {:foo => "bar"},
              :params => {}
            ) { {:metadata => {}} }
            model.create!
          end
        end

        context "with options" do
          it "sends create with appropriate arguments and options" do
            options = {:excellent => "billandted"}
            expect(client.base).to receive(:post).with("v2", :odd_endpoint,
              :content => :json,
              :accept => :json,
              :payload => {:foo => "bar"},
              :params => options
            ) { {:metadata => {}} }
            model.create!(options)
          end
        end

        it "clears diff" do
          expect(model.diff).to be_present
          model.create!
          expect(model.diff).not_to be_present
        end

        it "sets manifest from the response" do
          model.create!
          expect(model.manifest).to eq({
            :metadata => {
              :guid => "123",
              :created_at => "2013-06-10 10:41:15 -0700",
              :updated_at => "2015-06-10 10:41:15 -0700"
            }
          })
        end

        it "sets guid from the response metadata" do
          model.create!
          expect(model.guid).to eq("123")
        end

        it "sets timestamps from the response metadata" do
          model.create!

          expect(model.created_at).to eq(DateTime.parse("2013-06-10 10:41:15 -0700"))
          expect(model.updated_at).to eq(DateTime.parse("2015-06-10 10:41:15 -0700"))
        end
      end

      describe "#update!" do
        before do
          allow(client.base).to receive(:put) {
            {
              :metadata => {
                :guid => guid,
                :created_at => "2013-06-10 10:41:15 -0700",
                :updated_at => "2015-06-12 10:41:15 -0700"
              },
              :entity => {
                :foo => "updated"
              }
            }
          }
        end

        context "without options" do
          it "updates using the client with the v2 api, its plural model name, object guid, diff object, and empty params hash" do
            model.foo = "bar"
            expect(client.base).to receive(:put).with("v2", :test_models, guid,
              :content => :json,
              :accept => :json,
              :payload => {:foo => "bar"},
              :params => {}
            )
            model.update!
          end
        end

        context "with options" do
          it "sends update with the object guid, diff object and options" do
            model.foo = "bar"
            options = {:excellent => "billandted"}
            expect(client.base).to receive(:put).with("v2", :test_models, guid,
              :content => :json,
              :accept => :json,
              :payload => {:foo => "bar"},
              :params => options
            )
            model.update!(options)
          end
        end

        it "updates the updated_at timestamp" do
          model.update!
          expect(model.updated_at).to eq(DateTime.parse("2015-06-12 10:41:15 -0700"))
        end

        it "reloads it's data from the manifest" do
          model.update!
          expect(model.foo).to eq("updated")
        end

        it "clears diff" do
          model.foo = "bar"

          expect(model.diff).to be_present
          model.update!
          expect(model.diff).not_to be_present
        end
      end

      describe "delete" do
        it "uses #delete!" do
          expect(model).to receive(:delete!).with({}) { true }
          model.delete
        end

        it "passes options along to delete!" do
          expect(model).to receive(:delete!).with(:recursive => true) { true }
          model.delete(:recursive => true)
        end

        context "without errors" do
          it "returns true" do
            expect(model).to receive(:delete!).with({}) { true }
            expect(model.delete).to eq(true)
          end
        end

        context "with errors" do
          before do
            allow(model.class).to receive(:model_name) { ActiveModel::Name.new(model, nil, "abstract_model") }
            allow(model).to receive(:delete!) { raise CFoundry::APIError.new("HELP") }
          end

          it "does not raise an exception" do
            expect { model.delete }.to_not raise_error
          end

          it "returns false" do
            expect(model.delete).to eq(false)
          end

          context "without model-specific errors" do
            it "adds generic base error " do
              model.delete
              expect(model.errors.full_messages.first).to match(/cloud controller reported an error/i)
            end
          end

          context "with model-specific errors" do
            it "does not set the generic error on base" do
              model.delete
              expect(model.errors.size).to eq(1)
            end
          end
        end
      end

      describe "#delete!" do
        before { allow(client.base).to receive(:delete) }

        context "without options" do
          it "deletes using the client with the v2 api, its plural model name, object guid, and empty params hash" do
            expect(client.base).to receive(:delete).with("v2", :test_models, guid, :params => {})
            model.delete!
          end
        end

        context "with options" do
          it "sends delete with the object guid and options" do
            options = {:excellent => "billandted"}
            expect(client.base).to receive(:delete).with("v2", :test_models, guid, :params => options)

            model.delete!(options)
          end
        end

        it "clears its manifest metadata" do
          expect(model.manifest).to have_key(:metadata)
          model.delete!
          expect(model.manifest).not_to have_key(:metadata)
        end

        it "clears the diff" do
          model.foo = "bar"
          expect(model.diff).to be_present
          model.delete!
          expect(model.diff).not_to be_present
        end

        it "delete me" do
          begin
            model.delete!
          rescue => ex
            expect(ex.message).not_to match(/\?/)
          end
        end
      end

      describe "#to_key" do
        context "when persisted" do
          it "returns an enumerable containing the guid" do
            expect(model.to_key).to respond_to(:each)
            expect(model.to_key.first).to eq(guid)
          end
        end

        context "when not persisted" do
          let(:guid) { nil }

          it "returns nil" do
            expect(model.to_key).to be_nil
          end
        end
      end

      describe "#to_param" do
        context "when persisted" do
          it "returns the guid as a string" do
            expect(model.to_param).to be_a(String)
            expect(model.to_param).to eq(guid)
          end
        end

        context "when not persisted" do
          let(:guid) { nil }

          it "returns nil" do
            expect(model.to_param).to be_nil
          end
        end
      end

      describe "#persisted?" do
        context "on a new object" do
          let(:guid) { nil }
          it "returns false" do
            expect(model).not_to be_persisted
          end
        end

        context "on an object with a guid" do
          it "returns false" do
            expect(model).to be_persisted
          end
        end

        context "on an object that has been deleted" do
          before do
            allow(client.base).to receive(:delete)
            model.delete
          end

          it "returns false" do
            expect(model).not_to be_persisted
          end
        end
      end

      describe "metadata" do
        let(:new_object) { client.test_model }

        context "when metadata are set" do
          it "has timestamps" do
            expect(new_object.created_at).to be_nil
            expect(new_object.updated_at).to be_nil
          end
        end

        context "when metadata are not defined" do
          before do
            allow(new_object).to receive(:manifest).with(nil)
          end

          it "returns nil for timestamps" do
            expect(new_object.updated_at).to be_nil
            expect(new_object.updated_at).to be_nil
          end
        end
      end

      describe "creating a new object" do
        let(:new_object) { client.test_model }

        describe "getting attributes" do
          it "does not go to cloud controller" do
            expect {
              new_object.foo
            }.to_not raise_error
          end

          it "remembers set values" do
            new_object.foo = "bar"
            expect(new_object.foo).to eq("bar")
          end
        end

        describe "getting associations" do
          describe "to_one associations" do
            it "returns the an empty object of the association's type" do
              expect(new_object.domain.guid).to be_nil
            end
          end
        end
      end

      describe "first_page" do
        before do
          WebMock.stub_request(:get, /v2\/test_models/).to_return(:body => {
              "prev_url" => nil,
              "next_url" => next_url,
              "resources" => [{:metadata => {:guid => '1234'}}]
          }.to_json)
        end

        context "when there is a next page" do
          let(:next_url) { "/v2/test_models?&page=2&results-per-page=50" }
          before do
            WebMock.stub_request(:get, /v2\/test_models/).to_return(:body => {
                "prev_url" => nil,
                "next_url" => "/v2/test_models?&page=2&results-per-page=50",
                "resources" => [{:metadata => {:guid => '1234'}}]
            }.to_json)
          end

          it "has next_page set to true" do
            results = client.test_models_first_page
            expect(results[:next_page]).to be_truthy
            expect(results[:results].length).to eq(1)
            expect(results[:results].first).to be_a TestModel
          end
        end

        context "when there is no next page" do
          let(:next_url) { nil }

          it "has next_page set to false" do
            results = client.test_models_first_page
            expect(results[:next_page]).to be_falsey
          end
        end
      end

      describe '#for_each' do
        before do
          next_url = '/v2/test_models?page=2&q=timestamp%3E2012-11-01T12:00:00Z%3Btimestamp%3C2012-11-01T13:00:00Z&results-per-page=50'

          WebMock.stub_request(:get, /v2\/test_models\?inline-relations-depth=1/).to_return(:body => {
            'prev_url' => nil,
            'next_url' => next_url,
            'resources' => [{:metadata => {:guid => '1'}}, {:metadata => {:guid => '2'}}]
          }.to_json).times(1)

          WebMock.stub_request(:get, /#{Regexp.escape(next_url)}/).to_return(:body => {
            'prev_url' => nil,
            'next_url' => nil,
            'resources' => [{:metadata => {:guid => '3'}}]
          }.to_json).times(1)
        end

        it 'yields each page to the given the block' do
          results = []
          client.test_models_for_each do |test_model|
            results << test_model
          end
          expect(results.map(&:guid)).to eq(%w{1 2 3})
          expect(results.first).to be_a TestModel
        end
      end

      describe "#create_endpoint_name" do
        let(:default_model) { DefaultTestModel.new(guid, client, manifest) }

        it "defaults to the plural object name" do
          expect(default_model.create_endpoint_name).to eq(:default_test_models)
        end
      end
    end
  end
end
