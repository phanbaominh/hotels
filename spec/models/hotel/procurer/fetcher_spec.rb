require "rails_helper"

describe Hotel::Procurer::Fetcher do
  def response_body(supplier)
    [{supplier => true}].to_json
  end

  def all_suppliers
    Hotel::Procurer::SUPPLIERS
  end

  def build_expected_data(suppliers = all_suppliers)
    suppliers.each_with_object({}) do |supplier, hash|
      hash[supplier] = JSON.parse(response_body(supplier))
    end
  end

  context "when no error" do
    before do
      Hotel::Procurer::SUPPLIER_URLS.each do |supplier, url|
        response = Typhoeus::Response.new(code: 200, body: response_body(supplier))
        Typhoeus.stub(url).and_return(response)
      end
    end

    after { Typhoeus::Expectation.clear }

    it "returns data in correct shape" do
      expect(described_class.fetch).to match(build_expected_data)
    end

    describe "init hydra with max_concurrency" do
      before do
        allow(Typhoeus::Hydra).to receive(:new).and_call_original
      end

      context "when MAX_FETCHING_HOTELS_CONCURRENCY is set" do
        it "inits hydra with max_concurrency from env" do
          allow(ENV).to receive(:[]).with("MAX_FETCHING_HOTELS_CONCURRENCY").and_return("5")

          described_class.fetch

          expect(Typhoeus::Hydra).to have_received(:new).with(max_concurrency: 5)
        end
      end

      context "when MAX_FETCHING_HOTELS_CONCURRENCY is not set" do
        it "inits hydra with default max_concurrency" do
          described_class.fetch

          expect(Typhoeus::Hydra).to have_received(:new).with(max_concurrency: 3)
        end
      end
    end
  end

  context "when a supplier get error" do
    let(:error_supplier) { all_suppliers.sample }

    before do
      allow(Rails.logger).to receive(:error)
      Hotel::Procurer::SUPPLIER_URLS.each do |supplier, url|
        next if supplier == error_supplier

        response = Typhoeus::Response.new(code: 200, body: response_body(supplier))
        Typhoeus.stub(url).and_return(response)
      end
    end

    after { Typhoeus::Expectation.clear }

    shared_examples "returns data missing the error supplier with error message" do |error_message|
      it "returns data missing the error supplier" do
        expect(described_class.fetch).to match(build_expected_data(all_suppliers - [error_supplier]))
      end

      it "logs the error" do
        described_class.fetch

        expect(Rails.logger).to have_received(:error).with("Error fetching #{error_supplier}: " + error_message)
      end
    end

    context "when non-http response" do
      before do
        response = Typhoeus::Response.new(code: 0)
        allow(response).to receive(:return_message).and_return("unknown error")
        Typhoeus.stub(Hotel::Procurer::SUPPLIER_URLS[error_supplier]).and_return(response)
      end

      include_examples "returns data missing the error supplier with error message", "unknown error"
    end

    context "when error response code" do
      before do
        response = Typhoeus::Response.new(code: 500)
        Typhoeus.stub(Hotel::Procurer::SUPPLIER_URLS[error_supplier]).and_return(response)
      end

      include_examples "returns data missing the error supplier with error message", "HTTP request failed with 500"
    end

    context "when timeout" do
      before do
        response = Typhoeus::Response.new(code: 0)
        allow(response).to receive(:timed_out?).and_return(true)
        Typhoeus.stub(Hotel::Procurer::SUPPLIER_URLS[error_supplier]).and_return(response)
      end

      include_examples "returns data missing the error supplier with error message", "got a time out"
    end
  end
end
