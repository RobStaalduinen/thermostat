class ReadingsController < ApplicationController
  include Authorizable

  def show
    @reading = thermostat.readings.find_by!(number: params[:number])

    render json: @reading.data, status: 200
  end

  def create
    service = ThermostatReadingService.new(@thermostat)
    number = service.create_async(reading_params)
    render json: { number: number }, status: 200
  end

  private
    def reading_params
      params.require(:reading).permit(:temperature, :humidity, :battery_charge)
    end

end
