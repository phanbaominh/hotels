require "rails_helper"
require_relative "shared_examples"

describe Hotel::Procurer::MatchingRules::Nested do
  it_behaves_like "a matching rule" do
    subject {
      described_class.new({
        "merge" => Hotel::Procurer::MatchingRules::Merge.new,
        "pick_longest" => Hotel::Procurer::MatchingRules::PickLongest.new
      })
    }

    let(:field_values) do
      [
        {"merge" => {"a" => "1"}, "pick_longest" => "abc"},
        {"merge" => {"b" => "1"}, "pick_longest" => "abc def"},
        {"merge" => {"c" => "1"}, "pick_longest" => "a"}
      ]
    end

    let(:expected_field_value) do
      {"merge" => {"a" => "1", "b" => "1", "c" => "1"}, "pick_longest" => "abc def"}
    end
  end
end
