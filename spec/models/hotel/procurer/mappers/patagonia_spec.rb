require "rails_helper"

describe Hotel::Procurer::Mappers::Patagonia do
  let(:raw_data) do
    {
      "id" => "iJhz",
      "destination" => 5432,
      "name" => "Beach Villas Singapore",
      "lat" => 1.264751,
      "lng" => 103.824006,
      "address" => "8 Sentosa Gateway, Beach Villas, 098269",
      "info" => "A detailed description",
      "amenities" => [
        "Aircon",
        "Tv",
        "Coffee machine",
        "Kettle",
        "Hair dryer",
        "Iron",
        "Tub"
      ],
      "images" => {
        "rooms" => [
          {
            "url" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg",
            "description" => "Double room"
          },
          {
            "url" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg",
            "description" => "Bathroom"
          }
        ],
        "amenities" => [
          {
            "url" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg",
            "description" => "RWS"
          },
          {
            "url" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg",
            "description" => "Sentosa Gateway"
          }
        ]
      }
    }
  end
  let(:mapped_data) do
    {
      "id" => "iJhz",
      "destination_id" => 5432,
      "name" => "Beach Villas Singapore",
      "location" => {
        "lat" => 1.264751,
        "lng" => 103.824006,
        "address" => "8 Sentosa Gateway, Beach Villas, 098269"
      },
      "description" => "A detailed description",
      "amenities" => {
        "general" => [],
        "room" => ["aircon", "tv", "coffee machine", "kettle", "hair dryer", "iron", "bathtub"]
      },
      "images" => {
        "rooms" => [
          {
            "link" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg",
            "description" => "Double room"
          },
          {
            "link" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg",
            "description" => "Bathroom"
          }
        ],
        "amenities" => [
          {
            "link" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg",
            "description" => "RWS"
          },
          {
            "link" => "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg",
            "description" => "Sentosa Gateway"
          }
        ]
      },
      "booking_conditions" => nil
    }
  end

  it "maps data correctly" do
    expect(described_class.new.map(raw_data)).to match(mapped_data)
  end
end
