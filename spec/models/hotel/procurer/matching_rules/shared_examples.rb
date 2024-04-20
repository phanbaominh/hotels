RSpec.shared_examples "a matching rule" do
  subject { described_class.new }

  let(:field) { "field" }
  let(:data) do
    field_values.map.with_index do |field_value, i|
      supplier_data = {
        field => field_value
      }
      supplier_data["supplier"] = "supplier_#{i}"
      supplier_data
    end
  end

  context "when single PRESENT field value" do
    let(:single_field_value) { field_values.sample }
    let(:data) do
      [
        {field => single_field_value},
        {field => nil}
      ]
    end

    it "returns the single field value" do
      expect(subject.apply(field, data)).to eq(single_field_value)
    end
  end

  context "when multiple field values" do
    it "apply the rule to select one field value" do
      expect(subject.apply(field, data)).to eq(expected_field_value)
    end
  end
end
