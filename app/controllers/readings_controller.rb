class ReadingsController < ApplicationController
  include Authorizable

  def show
    render json: {}, status: 200
  end

  def create
    number = 1 # Assign temporary sequence
    ReadingPersister.perform_async(
      thermostat.id,
      reading_params.merge({number: number}).to_json
    )
    render json: {}, status: 200
  end

  private
    def reading_params
      params.require(:reading).permit(:temperature, :humidity, :battery_charge)
    end

end
