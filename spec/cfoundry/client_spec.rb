require "spec_helper"

describe CFoundry::Client do
  before do
    allow_any_instance_of(CFoundry::V2::Client).to receive(:info)
  end

  subject { CFoundry::Client.get('http://example.com') }

  it "returns a v2 client" do
    expect(subject).to be_a(CFoundry::V2::Client)
  end
end
