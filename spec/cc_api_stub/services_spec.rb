require 'spec_helper'
require 'net/http'
require 'uri'

describe CcApiStub::Services do
  describe '.service_fixture_hash' do
    it 'returns the fake services' do
      expect(CcApiStub::Services.service_fixture_hash).to be_a(Hash)
    end
  end
end
