class ReadingsController < ApplicationController
  include Authorizable

  def show
    render json: {}, status: 200
  end

  def create
    render json: {}, status: 200
  end

end
