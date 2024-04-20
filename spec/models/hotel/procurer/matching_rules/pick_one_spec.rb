require "rails_helper"
require_relative "shared_examples"

describe Hotel::Procurer::MatchingRules::PickOne do
  it_behaves_like "a matching rule" do
    let(:field_values) { ["1", "1", "1"] }

    let(:expected_field_value) { "1" }
  end
end
