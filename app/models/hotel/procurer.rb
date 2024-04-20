require "open-uri"

class Hotel::Procurer
  # PROBLEMS:
  #  "1 Nanson Rd, Singapore 238909" what is the correct address format?
  # site - Bar, amenities - Bar -> wrong description for amenities - Bar https://d2ey9sqrvkqdfs.cloudfront.net/YwAr/i57_m.jpg, should be breakfast
  # dead image for https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg
  # almost duplicated image for https://d2ey9sqrvkqdfs.cloudfront.net/YwAr/i1_m.jpg && https://d2ey9sqrvkqdfs.cloudfront.net/YwAr/i10_m.jpg

  SUPPLIERS = [
    ACME = "acme",
    PAPERFLIES = "paperflies",
    PATAGONIA = "patagonia"
  ].freeze

  SUPPLIER_URLS = {
    ACME => "https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme",
    PAPERFLIES => "https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/paperflies",
    PATAGONIA => "https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/patagonia"
  }.freeze

  SUPPLIER_DATA_MAPPER = {
    ACME => Hotel::Procurer::Mappers::Acme.new,
    PAPERFLIES => Hotel::Procurer::Mappers::Paperflies.new,
    PATAGONIA => Hotel::Procurer::Mappers::Patagonia.new
  }.freeze

  SUPPLIER_KEY = "supplier"

  UNIQUE_CONCAT_IMAGE = MatchingRules::UniqueConcat.new { |image| image["link"] }.freeze

  RULES = {
    "id" => MatchingRules::PickOne.new,
    "destination_id" => MatchingRules::PickOne.new,
    # in real app, should query some external site to match the name and the address correctly
    "name" => MatchingRules::PriorityPickOne.new([ACME]),
    "location" => MatchingRules::Merge.new,
    "description" => MatchingRules::PickLongest.new,
    "amenities" => MatchingRules::Nested.new(
      {
        "general" => MatchingRules::UniqueConcat.new,
        "room" => MatchingRules::UniqueConcat.new
      }
    ),
    "images" => MatchingRules::Nested.new(
      {
        "rooms" => UNIQUE_CONCAT_IMAGE,
        "site" => UNIQUE_CONCAT_IMAGE,
        "amenities" => UNIQUE_CONCAT_IMAGE
      }
    ),
    "booking_conditions" => MatchingRules::PickOne.new
  }.freeze

  def procure
    group_by_hotel(hotels_data_from_all_suppliers).transform_values do |hotel_data|
      hotel_attributes = matcher.match(hotel_data)
      after_match(hotel_attributes)
      hotel_attributes
    end.values
  end

  private

  def after_match(hotel_attributes)
    remove_less_specific_amenity(hotel_attributes) # e.g remove 'pool' if 'indoor/outdoor pool' exists
  end

  def remove_less_specific_amenity(hotel_attributes)
    hotel_attributes["amenities"].transform_values! do |amenities|
      amenities.select do |amenity|
        amenities.none? { |other| other != amenity && other.include?(amenity) }
      end.sort
    end
  end

  def hotels_data_from_all_suppliers
    SUPPLIERS.map do |supplier|
      fetch_data(supplier).map do |hotel_data|
        mapped_data = mapper(supplier).map(clean(hotel_data))
        mapped_data[SUPPLIER_KEY] = supplier
        mapped_data
      end
    end.flatten
  end

  def group_by_hotel(hotels_data)
    hotels_data.group_by { |hotel| hotel["id"] }
  end

  def mapper(supplier)
    SUPPLIER_DATA_MAPPER[supplier]
  end

  def clean(data)
    Cleaner.clean(data)
  end

  def fetch_data(supplier)
    # TODO: use Faraday, error handling, etc

    file = URI.parse(SUPPLIER_URLS[supplier]).open
    raw_data = file.read
    JSON.parse(raw_data)
  end

  def matcher
    @matcher ||= Hotel::Procurer::Matcher.new(RULES)
  end
end
