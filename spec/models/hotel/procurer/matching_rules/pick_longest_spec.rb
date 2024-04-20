require "rails_helper"
require_relative "shared_examples"

describe Hotel::Procurer::MatchingRules::PickLongest do
  it_behaves_like "a matching rule" do
    let(:field_values) { ["abc", "abc def", "a"] }

    let(:expected_field_value) { "abc def" }
  end
end
