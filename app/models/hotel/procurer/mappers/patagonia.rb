module Hotel::Procurer::Mappers
  class Patagonia < Base
    def destination_id
      data["destination"]
    end

    def location
      {
        "lat" => data["lat"],
        "lng" => data["lng"],
        "address" => data["address"]
      }
    end

    def description
      data["info"]
    end

    def amenities
      classified_amenities(data["amenities"]) || super
    end

    def images
      raw_images = super
      raw_images.each_with_object({}) do |(key, images), hash|
        hash[key] = map_images(images)
      end
    end

    def map_images(images)
      images.map do |image|
        {
          "link" => image["url"],
          "description" => image["description"]
        }
      end
    end
  end
end
