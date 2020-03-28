class ReadingsController < ApplicationController
  include Authorizable

  def show
    @reading = thermostat.readings.find_by!(number: params[:number])

    render json: @reading.data, status: 200
  end

  def create
    number = next_sequence_number
    ReadingPersister.perform_async(
      thermostat.id,
      reading_params.merge({number: number}).to_json
    )
    render json: { number: number }, status: 200
  end

  private
    def reading_params
      params.require(:reading).permit(:temperature, :humidity, :battery_charge)
    end

    # To be refactored elsewhere
    def next_sequence_number
      Reading.
        joins(:thermostat).
        where(thermostats: { household_token: thermostat.household_token }).
        count + 1
    end

end
