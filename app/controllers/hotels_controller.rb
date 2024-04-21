class HotelsController < ApplicationController
  def index
    # if we can assume procured data is changed infrequently, we can cache it
    service = Hotels::Index.new(index_params, use_cache: true)

    render json: service.call.data
  end

  private

  def index_params
    params.permit(:destination, hotels: [])
  end
end
