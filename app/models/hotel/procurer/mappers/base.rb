class Hotel::Procurer::Mappers::Base
  def initialize(data)
    @data = data
  end

  def map
    {
      "id" => id,
      "destination_id" => destination_id,
      "name" => name,
      "location" => location,
      "description" => description,
      "amenities" => amenities,
      "images" => images,
      "booking_conditions" => booking_conditions
    }
  end

  private

  attr_reader :data

  def id
    data["id"]
  end

  def destination_id
    data["destination_id"]
  end

  def name
    data["name"]
  end

  def location
    data["location"] || {}
  end

  def description
    data["description"]
  end

  def amenities
    data["amenities"] || {}
  end

  def images
    data["images"] || {}
  end

  def booking_conditions
    data["booking_conditions"] || []
  end

  def classified_amenities(raw_amenities)
    return raw_amenities unless raw_amenities.is_a?(Array)

    Hotel::Procurer::AmenityClassifier.new(raw_amenities).classify
  end
end
