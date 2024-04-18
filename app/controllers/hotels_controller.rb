class HotelsController < ApplicationController
  def index
    render json: Hotel.new
  end
end
