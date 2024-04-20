class Hotel::Procurer::Mappers::Base
  def map(data)
    @data = data
    result = {
      "id" => id,
      "destination_id" => destination_id,
      "name" => name,
      "location" => location,
      "description" => description,
      "amenities" => amenities,
      "images" => images,
      "booking_conditions" => booking_conditions
    }
    after_map(result)
  end

  def after_map(result)
    if result["location"]["country"]
      result["location"]["country"] = standardized_country(result["location"]["country"])
    end
    result
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
    location = data["location"] || {}
    location["country"] = standardized_country(location["country"])
    location
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

  def standardized_country(raw_value)
    return raw_value if raw_value.blank?

    (
      ISO3166::Country.new(raw_value) || ISO3166::Country.find_country_by_any_name(raw_value)
    )&.iso_short_name || raw_value
  end
end
