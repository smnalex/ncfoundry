require 'spec_helper'

describe 'Errors' do
  describe CFoundry::Timeout do
    let(:parent) { Timeout::Error.new }

    subject { CFoundry::Timeout.new("POST", '/blah', parent) }

    describe '#to_s' do
      subject { super().to_s }
      it { should eq "POST /blah timed out" }
    end

    describe '#method' do
      subject { super().method }
      it { should eq "POST" }
    end

    describe '#uri' do
      subject { super().uri }
      it { should eq '/blah' }
    end

    describe '#parent' do
      subject { super().parent }
      it { should eq parent }
    end
  end

  describe CFoundry::InvalidTarget do
    let(:target) { "http://--foo-bar" }
    subject { CFoundry::InvalidTarget.new(target) }

    describe '#to_s' do
      subject { super().to_s }
      it { should eq "Invalid target URI: #{target}"}
    end

    describe '#target' do
      subject { super().target }
      it { should eq target }
    end
  end

  describe CFoundry::APIError do
    let(:request) { { :method => "GET", :url => "http://api.example.com/foo", :headers => {} } }
    let(:response_body) { "NOT FOUND" }
    let(:response) { { :status => 404, :headers => {}, :body => response_body } }

    subject { CFoundry::APIError.new(nil, nil, request, response) }

    describe '#to_s' do
      subject { super().to_s }
      it { should eq "404: NOT FOUND" }
    end

    describe '#request' do
      subject { super().request }
      it { should eq request }
    end

    describe '#response' do
      subject { super().response }
      it { should eq response }
    end

    describe "#initialize" do

      context "Response body is JSON" do

        let(:response_body) { "{\"description\":\"Something went wrong\"}"}

        it "sets description to description field in parsed JSON" do
          expect(CFoundry::APIError.new(nil, nil, request, response).description).to eq("Something went wrong")
        end
      end


      context "Response body is not JSON" do

        let(:response_body) { "Some plain text"}

        it "sets description to body text" do
          expect(CFoundry::APIError.new(nil, nil, request, response).description).to eq("Some plain text")
        end
      end

      it "allows override of description" do
        expect(CFoundry::APIError.new("My description", nil, request, response).description).to eq("My description")
      end

    end

    describe "#request_trace" do
      describe '#request_trace' do
        subject { super().request_trace }
        it { should include "REQUEST: " }
      end
    end

    describe "#response_trace" do
      describe '#response_trace' do
        subject { super().response_trace }
        it { should include "RESPONSE: " }
      end
    end

    it "sets error code to response error code by default" do
      expect(CFoundry::APIError.new(nil, nil, request, response).error_code).to eq(404)
    end

    it "allows override of error code" do
      expect(CFoundry::APIError.new(nil, 303, request, response).error_code).to eq(303)
    end

  end
end
