class HotelsController < ApplicationController
  def index
    service = Hotels::Index.new(index_params, use_cache: true)

    render json: service.call.data
  end

  private

  def index_params
    params.permit(:destination, hotels: [])
  end
end
