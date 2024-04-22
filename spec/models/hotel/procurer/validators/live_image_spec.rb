require "rails_helper"

describe Hotel::Procurer::Validators::LiveImage do
  let(:room_image_link_1) do
    "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg"
  end
  let(:room_image_link_2) do
    "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg"
  end
  let(:site_image_link) do
    "https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg"
  end
  let(:all_image_links) do
    [room_image_link_1, room_image_link_2, site_image_link]
  end
  let(:hotel_data) do
    {
      "images" => {
        "rooms" => [
          {
            "link" => room_image_link_1,
            "description" => "Double room"
          },
          {
            "link" => room_image_link_2,
            "description" => "Double room"
          }
        ],
        "site" => [
          {
            "link" => site_image_link,
            "description" => "Front"
          }
        ]
      }
    }
  end

  def all_suppliers
    Hotel::Procurer::SUPPLIERS
  end

  context "when no error" do
    let(:expected_data) do
      hotel_data.deep_dup
    end

    before do
      all_image_links.each do |image_link|
        response = Typhoeus::Response.new(code: 200)
        Typhoeus.stub(image_link).and_return(response)
      end
    end

    after { Typhoeus::Expectation.clear }

    it "returns data in correct shape" do
      described_class.validate!(hotel_data)

      expect(hotel_data).to match(expected_data)
    end

    describe "init hydra with max_concurrency" do
      before do
        allow(Typhoeus::Hydra).to receive(:new).and_call_original
      end

      context "when MAX_FETCHING_IMAGE_CONCURRENCY is set" do
        it "inits hydra with max_concurrency from env" do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with("MAX_FETCHING_IMAGE_CONCURRENCY").and_return("5")

          described_class.validate!(hotel_data)

          expect(Typhoeus::Hydra).to have_received(:new).with(max_concurrency: 5)
        end
      end
    end
  end

  context "when an image get error" do
    let(:error_image) { room_image_link_2 }
    let(:expected_data) do
      {
        "images" => {
          "rooms" => [
            {
              "link" => room_image_link_1,
              "description" => "Double room"
            }
          ],
          "site" => [
            {
              "link" => site_image_link,
              "description" => "Front"
            }
          ]
        }
      }
    end

    before do
      allow(Rails.logger).to receive(:error)
      (all_image_links - [error_image]).each do |image_link|
        next if image_link == error_image

        response = Typhoeus::Response.new(code: 200)
        Typhoeus.stub(image_link).and_return(response)
      end

      error_response = Typhoeus::Response.new(code: 500)
      Typhoeus.stub(error_image).and_return(error_response)
    end

    it "returns hotel data without dead image link" do
      described_class.validate!(hotel_data)

      expect(hotel_data).to match(expected_data)
    end

    it "logs the error" do
      described_class.validate!(hotel_data)

      expect(Rails.logger).to have_received(:error).with("Error fetching image from #{error_image}: " + "HTTP request failed with 500")
    end
  end
end
