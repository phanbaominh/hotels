require "rails_helper"

describe Hotel::Procurer::Mappers::Acme do
  let(:raw_data) do
    {
      "Id" => "iJhz",
      "DestinationId" => 5432,
      "Name" => "Beach Villas Singapore",
      "Latitude" => 1.264751,
      "Longitude" => nil,
      "Address" => "8 Sentosa Gateway, Beach Villas",
      "City" => "Singapore",
      "Country" => "SG",
      "PostalCode" => "098269",
      "Description" => "This 5 star hotel is located on the coastline of Singapore.",
      "Facilities" => [
        "Pool",
        "BusinessCenter",
        "WiFi",
        "DryCleaning",
        "Breakfast"
      ]
    }
  end
  let(:mapped_data) do
    {
      "id" => "iJhz",
      "destination_id" => 5432,
      "name" => "Beach Villas Singapore",
      "location" => {
        "lat" => 1.264751,
        "address" => "8 Sentosa Gateway, Beach Villas, 098269",
        "city" => "Singapore",
        "country" => "Singapore"
      },
      "description" => "This 5 star hotel is located on the coastline of Singapore.",
      "amenities" => {
        "general" => [
          "pool", "business center", "wifi", "dry cleaning", "breakfast"
        ],
        "room" => []
      },
      "images" => {},
      "booking_conditions" => nil
    }
  end

  it "maps data correctly" do
    expect(described_class.new.map(raw_data)).to match(mapped_data)
  end
end
