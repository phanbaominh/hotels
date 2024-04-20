require "rails_helper"
require_relative "shared_examples"

describe Hotel::Procurer::MatchingRules::PriorityPickOne do
  let(:priorities) { ["supplier_1", "supplier_2"] }

  context "when prioritized supplier value is nil" do
    describe "returning the next supplier value" do
      it_behaves_like "a matching rule" do
        subject { described_class.new(priorities) }

        let(:field_values) { ["1", nil, "3"] }

        let(:expected_field_value) { "3" }
      end
    end
  end

  context "when all prioritized supplier values is nil" do
    describe "returning any present value" do
      it_behaves_like "a matching rule" do
        subject { described_class.new(priorities) }

        let(:field_values) { ["1", nil, nil] }

        let(:expected_field_value) { "1" }
      end
    end
  end

  context "when all prioritized supplier values is not nil" do
    describe "returning the first prioritized supplier value" do
      it_behaves_like "a matching rule" do
        subject { described_class.new(priorities) }

        let(:field_values) { ["1", "2", "3"] }

        let(:expected_field_value) { "2" }
      end
    end
  end
end
