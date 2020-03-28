class StatsController < ApplicationController
  include Authorizable

  def index
    render json: {}, status: 200
  end
end
