module Hotels
  class Index
    attr_reader :data

    def initialize(params)
      @params = params
    end

    def call
      @data = procure_data
      filter_by_hotel_ids
      filter_by_destination

      self
    end

    private

    attr_reader :params

    def filter_by_destination
      return if params[:destination].blank?

      @data.select! { |hotel| hotel["destination_id"] == params[:destination].to_i }
    end

    def filter_by_hotel_ids
      return if params[:hotels].blank?

      @data.select! { |hotel| params[:hotels].include?(hotel["id"]) }
    end

    def procure_data
      Hotel::Procurer.new.procure
    end
  end
end
