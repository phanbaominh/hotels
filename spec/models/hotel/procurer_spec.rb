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
    allow(Hotel::Procurer::Validators::LiveImage).to receive(:validate!)
  end

  let(:expected_data) do
    JSON.parse(File.read("spec/fixtures/procure/procured.json"))
  end

  it "returns a list of hotels" do
    expect(subject.procure).to match(
      expected_data
    )
  end

  it "calls validator once for each hotel data" do
    subject.procure

    expect(Hotel::Procurer::Validators::LiveImage).to have_received(:validate!).exactly(3).times
  end
end
