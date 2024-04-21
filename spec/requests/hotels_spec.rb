require "rails_helper"

RSpec.describe "Hotels", type: :request do
  describe "GET #index" do
    let(:params) { {destination: "1", hotels: ["1", "2", "3"]} }
    let(:index_service) { instance_double(Hotels::Index, data: data) }
    let(:data) { [{"id" => 1, "destination_id" => 1}] }

    before do
      allow(Hotels::Index).to receive(:new).and_return(index_service)
      allow(index_service).to receive(:call).and_return(index_service)
      get "/hotels", params: params
    end

    it "returns correct response" do
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(data)
    end

    it "calls service correctly" do
      expect(Hotels::Index).to have_received(:new)
        .with(ActionController::Parameters.new(params).permit!, use_cache: true)
    end
  end
end
