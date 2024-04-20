module Hotel::Procurer::Mappers
  class Paperflies < Base
    private

    def id
      data["hotel_id"]
    end

    def name
      data["hotel_name"]
    end

    def description
      data["details"]
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
          "link" => image["link"],
          "description" => image["caption"]
        }
      end
    end
  end
end
