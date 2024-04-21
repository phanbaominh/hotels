module Hotels
  class Index
    attr_reader :data

    def initialize(params, use_cache: false)
      @params = params
      @use_cache = use_cache
    end

    def call
      @data = procure_data
      filter_by_hotel_ids
      filter_by_destination

      self
    end

    private

    attr_reader :params, :use_cache

    def filter_by_destination
      return if params[:destination].blank?

      @data.select! { |hotel| hotel["destination_id"] == params[:destination].to_i }
    end

    def filter_by_hotel_ids
      return if params[:hotels].blank?

      @data.select! { |hotel| params[:hotels].include?(hotel["id"]) }
    end

    def procure_data
      if use_cache
        Rails.cache.fetch("hotels", expires_in: cache_expiration) do
          Hotel::Procurer.new.procure
        end
      else
        Hotel::Procurer.new.procure
      end
    end

    def cache_expiration
      (ENV["PROCURE_CACHE_EXPIRATION"] || 1).to_i.minute
    end
  end
end
