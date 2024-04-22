module Hotel::Procurer::Validators
  class LiveImage
    class << self
      def validate!(hotel_data)
        hydra = Typhoeus::Hydra.new(
          max_concurrency: (ENV["MAX_FETCHING_IMAGE_CONCURRENCY"] || 3).to_i
        )

        hotel_data["images"].values.flatten.pluck("link").each do |image_link|
          hydra.queue(build_request(image_link))
        end

        hydra.run

        hotel_data["images"].each do |image_type, images|
          images.select! { |image| dead_image_links.exclude?(image["link"]) }
        end
      end

      private

      def build_request(image_link)
        TyphoeusRequest.build(image_link, timeout: timeout) do |response, error_message|
          unless response.success?
            dead_image_links << image_link
            log_error(image_link, error_message)
          end
        end
      end

      def dead_image_links
        @dead_image_links ||= []
      end

      def timeout
        ENV["MAX_FETCHING_IMAGE_TIMEOUT"] || 10
      end

      def log_error(image_link, msg)
        Rails.logger.error("Error fetching image from #{image_link}: #{msg}")
      end
    end
  end
end
