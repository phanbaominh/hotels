# In a real app, each suppplier would have data for thoudsands of hotels so this approach is unlikely to scale.
# And there would be more than 3 suppliers.
# We could have a solution like running a job for each supplier, collecting all the data and store it to files
# Then we have a separate job to combine all the data from the files and process and store them.
# This can be done frequently to keep the data up-to-date.


class Hotel::Procurer
  class Fetcher
    class << self
      def fetch
        hydra = Typhoeus::Hydra.new(
          # Simply choose 3 as the default because we have 3 suppliers
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
        TyphoeusRequest.build(SUPPLIER_URLS[supplier], timeout: timeout) do |response, error_message|
          if response.success?
            data[supplier] = JSON.parse(response.body)
          else
            log_error(supplier, error_message)
          end
        end
      end

      def timeout
        ENV["FETCHING_HOTELS_TIMEOUT"] || 3
      end

      def log_error(supplier, msg)
        Rails.logger.error("Error fetching #{supplier}: #{msg}")
      end
    end
  end
end
