require "rails_helper"

describe Hotels::Index do
  let(:params) { {destination: "1", hotels: ["a", "b"]} }
  let(:instance) { described_class.new(params) }

  describe "#call" do
    let(:procured_data) { [{"id" => "a", "destination_id" => 1}, {"id" => "b", "destination_id" => 2}, {"id" => "c", "destination_id" => 1}] }
    let(:filtered_data) { [{"id" => "a", "destination_id" => 1}] }

    before do
      allow_any_instance_of(Hotel::Procurer).to receive(:procure).and_return(procured_data)
    end

    it "filters data based on params" do
      expect(instance.call.data).to eq(filtered_data)
    end
  end
end
