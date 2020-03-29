class ReadingsController < ApplicationController
  include Authorizable

  def show
    @reading = thermostat_service.find_by_number(params[:number])
    
    render json: @reading.data, status: 200
  end

  def create
    number = thermostat_service.create_async(reading_params)
    render json: { number: number }, status: 200
  end

  private
    def reading_params
      params.require(:reading).permit(:temperature, :humidity, :battery_charge)
    end

    def thermostat_service
      @service ||= ThermostatReadingService.new(@thermostat)
    end

end
