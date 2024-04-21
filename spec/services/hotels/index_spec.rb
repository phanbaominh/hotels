require "rails_helper"

describe Hotels::Index do
  let(:params) { {destination: "1", hotels: ["a", "b"]} }
  let(:service) { described_class.new(params) }

  describe "#call" do
    let(:procured_data) { [{"id" => "a", "destination_id" => 1}, {"id" => "b", "destination_id" => 2}, {"id" => "c", "destination_id" => 1}] }
    let(:filtered_data) { [{"id" => "a", "destination_id" => 1}] }

    before do
      allow(Rails.cache).to receive(:fetch).and_return(procured_data)
      allow_any_instance_of(Hotel::Procurer).to receive(:procure).and_return(procured_data)
    end

    it "filters data based on params" do
      expect(service.call.data).to eq(filtered_data)
      expect(Rails.cache).not_to have_received(:fetch)
    end

    context "when use_cache is true" do
      let(:service) { described_class.new(params, use_cache: true) }

      it "fetches data from cache" do
        expect(service.call.data).to eq(filtered_data)

        expect(Rails.cache).to have_received(:fetch).with("hotels", expires_in: 1.minute)
      end

      context "when setting PROCURE_CACHE_EXPIRATION" do
        it "fetches data from cache with the correct expiration" do
          allow(ENV).to receive(:[]).with("PROCURE_CACHE_EXPIRATION").and_return("5")

          service.call

          expect(Rails.cache).to have_received(:fetch).with("hotels", expires_in: 5.minutes)
        end
      end
    end
  end
end
