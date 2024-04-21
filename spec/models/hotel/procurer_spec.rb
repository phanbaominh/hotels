require "rails_helper"

describe Hotel::Procurer do
  subject { described_class.new }

  before do
    allow(subject)
      .to receive(:fetch_data)
      .and_return(
        described_class::SUPPLIERS.each_with_object({}) do |supplier, hash|
          hash[supplier] = JSON.parse(File.read("spec/fixtures/procure/#{supplier}.json"))
        end
      )
  end

  let(:expected_data) do
    JSON.parse(File.read("spec/fixtures/procure/procured.json"))
  end

  it "returns a list of hotels" do
    expect(subject.procure).to match(
      expected_data
    )
  end
end
