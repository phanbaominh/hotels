require "rails_helper"
require_relative "shared_examples"

describe Hotel::Procurer::MatchingRules::Merge do
  it_behaves_like "a matching rule" do
    let(:field_values) do
      [
        {
          "lat" => 1.264751,
          "lng" => 103.824006,
          "address" => "8 Sentosa Gateway, Beach Villas, 098269",
          "city" => "Singapore",
          "country" => "Singapore"
        },
        {
          "address" => "8 Sentosa Gateway, Beach Villas, 098269",
          "country" => "Singapore"
        },
        {
          "lat" => 1.264751,
          "lng" => 103.824006,
          "address" => "8 Sentosa Gateway, Beach Villas, 098269"
        }
      ]
    end

    let(:expected_field_value) do
      {
        "lat" => 1.264751,
        "lng" => 103.824006,
        "address" => "8 Sentosa Gateway, Beach Villas, 098269",
        "city" => "Singapore",
        "country" => "Singapore"
      }
    end
  end
end
