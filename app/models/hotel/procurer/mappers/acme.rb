module Hotel::Procurer::Mappers
  class Acme < Base
    private

    def id
      data["Id"]
    end

    def destination_id
      data["DestinationId"]
    end

    def name
      data["Name"]
    end

    def location
      {
        "lat" => data["Latitude"],
        "lng" => data["Longitude"],
        "address" => address,
        "city" => data["City"],
        "country" => data["Country"]
      }
    end

    def description
      data["Description"]
    end

    def amenities
      classified_amenities(data["Facilities"]) || super
    end

    def address
      if data["Address"]&.include?(data["PostalCode"])
        data["Address"]
      else
        [data["Address"], data["PostalCode"]].compact.join(", ")
      end
    end
  end
end
