class Hotel::Procurer::AmenityClassifier
  ROOM_AMENITIES = ["aircon", "tv", "coffee machine", "kettle", "hair dryer", "iron", "bathtub", "minibar"].freeze

  STANDARD_DICT = {
    "tub" => "bathtub",
    "bath tub" => "bathtub",
    "wi fi" => "wifi"
  }

  def initialize(amenities)
    @amenities = standardize(amenities)
  end

  def classify
    {
      "general" => general,
      "room" => room
    }
  end

  private

  attr_reader :amenities

  def general
    # room amenities should be a more limited set so we can easily list out all of them
    amenities - room
  end

  def room
    amenities.select do |amenity|
      ROOM_AMENITIES.include?(amenity)
    end
  end

  def standardize(amenities)
    amenities.map do |amenity|
      amenity = amenity.underscore.humanize.downcase
      STANDARD_DICT[amenity] || amenity
    end
  end
end
