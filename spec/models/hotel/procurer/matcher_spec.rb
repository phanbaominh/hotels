require "rails_helper"

describe Hotel::Procurer::Matcher do
  subject {
    described_class.new({
      "merge" => Hotel::Procurer::MatchingRules::Merge.new,
      "pick_longest" => Hotel::Procurer::MatchingRules::PickLongest.new
    })
  }

  let(:data) do
    [
      {"merge" => {"a" => "1"}, "pick_longest" => "abc"},
      {"merge" => {"b" => "1"}, "pick_longest" => "abc def"},
      {"merge" => {"c" => "1"}, "pick_longest" => "a"}
    ]
  end

  let(:expected_field_value) do
    {"merge" => {"a" => "1", "b" => "1", "c" => "1"}, "pick_longest" => "abc def"}
  end

  it "matches the data based on the rules" do
    expect(subject.match(data)).to eq(expected_field_value)
  end
end
