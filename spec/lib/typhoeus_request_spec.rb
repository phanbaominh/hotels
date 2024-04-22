require "rails_helper"

describe TyphoeusRequest do
  let(:stub_url) { "http://example.com" }

  context "when success" do
    it "yields response" do
      success_response = Typhoeus::Response.new(code: 200)
      Typhoeus.stub(stub_url).and_return(success_response)

      TyphoeusRequest.build(stub_url) do |response, error_message|
        expect(response).to eq(success_response)
        expect(error_message).to be_nil
      end
    end
  end

  shared_examples "yielding error message" do |error_message|
    it "yield errors" do
      Typhoeus.stub(stub_url).and_return(response)

      TyphoeusRequest.build(stub_url) do |response, error_message|
        expect(error_message).to eq(error_message)
      end
    end
  end

  context "when non-http response" do
    let(:response) { Typhoeus::Response.new(code: 0) }

    before do
      allow(response).to receive(:return_message).and_return("unknown error")
    end

    include_examples "yielding error message", "unknown error"
  end

  context "when error response code" do
    let(:response) { Typhoeus::Response.new(code: 500) }

    include_examples "yielding error message", "HTTP request failed with 500"
  end

  context "when timeout" do
    let(:response) { Typhoeus::Response.new(code: 0) }

    before do
      allow(response).to receive(:timed_out?).and_return(true)
    end

    include_examples "yielding error message", "got a time out"
  end
end
