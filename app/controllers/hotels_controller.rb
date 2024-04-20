class HotelsController < ApplicationController
  def index
    service = Hotels::Index.new(index_params)

    render json: service.call.data
  end

  private

  def index_params
    params.permit(:destination, hotels: [])
  end
end
