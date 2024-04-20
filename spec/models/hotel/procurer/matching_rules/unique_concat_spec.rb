require "rails_helper"
require_relative "shared_examples"

describe Hotel::Procurer::MatchingRules::UniqueConcat do
  it_behaves_like "a matching rule" do
    let(:field_values) do
      [
        ["pool", "business center", "wifi", "dry cleaning", "breakfast"],
        [
          "outdoor pool",
          "indoor pool",
          "business center",
          "childcare"
        ]
      ]
    end

    let(:expected_field_value) {
      ["pool", "business center", "wifi", "dry cleaning", "breakfast", "outdoor pool", "indoor pool", "childcare"]
    } 
  end
end
