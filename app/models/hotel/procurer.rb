# frozen_string_literal: true

class Hotel::Procurer
  # PROBLEMS:
  # 1. Address format is not consistent across suppliers
  # Addresses can be considered to be usable if users can search on Google and the search result return the right hotel
  # Unless there is a need like FE requiring the address to be in a specific format, we can leave it as it is.

  # 2. Image descriptions are not correct
  # Wrong description for images shall be ignored in this implementation for simplicity.
  # In a real app, we would ideally have a system in place to manually verify the correctness of the hotels data presented to users.
  # OR a ML solution to identify the objects in the image to validate.

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
    # acme and patagonia supplier provide the full name of the hotel compare to paperflies e.g InterContinental Singapore Robertson Quay vs InterContinental
    # There are two InterContinental hotels in Singapore so the full name help to differentiate them.
    # pagatonia give more correct name compare to acme e.g Hilton Tokyo Shinjuku vs Hilton Shinjuku Tokyo. The most correct would be Hilton Tokyo.
    # Of course if there are more data given for each supplier, we can make a better decision on which supplier to prioritize.
    # We can also implement a more robust approach like searching the hotel name on google and see if the search result return the right hotel.
    "name" => MatchingRules::PriorityPickOne.new([PATAGONIA, ACME]),
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
    "booking_conditions" => MatchingRules::PriorityPickOne.new([PAPERFLIES])
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
    remove_dead_image_links(hotel_attributes)
  end

  def remove_dead_image_links(hotel_attributes)
    Validators::LiveImage.validate!(hotel_attributes)
  end

  def remove_less_specific_amenity(hotel_attributes)
    hotel_attributes["amenities"].transform_values! do |amenities|
      amenities.select do |amenity|
        amenities.none? { |other| other != amenity && other.include?(amenity) }
      end.sort
    end
  end

  def hotels_data_from_all_suppliers
    fetch_data.map do |supplier, hotels_data|
      hotels_data.map do |hotel_data|
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

  def fetch_data
    Fetcher.fetch
  end

  def matcher
    @matcher ||= Hotel::Procurer::Matcher.new(RULES)
  end
end
