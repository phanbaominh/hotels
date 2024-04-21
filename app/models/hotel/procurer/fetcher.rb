class Hotel::Procurer
  class Fetcher
    class << self
      def fetch
        hydra = Typhoeus::Hydra.new(
          max_concurrency: (ENV["MAX_FETCHING_HOTELS_CONCURRENCY"] || 3).to_i
        )
        data = {}

        SUPPLIERS.each do |supplier|
          hydra.queue(build_request(supplier, data))
        end

        hydra.run
        data
      end

      private

      def build_request(supplier, data)
        request = Typhoeus::Request.new(SUPPLIER_URLS[supplier])

        request.on_complete do |response|
          if response.success?
            data[supplier] = JSON.parse(response.body)
          elsif response.timed_out?
            log_error(supplier, "got a time out")
          elsif response.code == 0
            log_error(supplier, response.return_message)
          else
            log_error(supplier, "HTTP request failed with " + response.code.to_s)
          end
        end
        request
      end

      def log_error(supplier, msg)
        Rails.logger.error("Error fetching #{supplier}: #{msg}")
      end
    end
  end
end
