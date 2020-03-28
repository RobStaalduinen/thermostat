class StatsController < ApplicationController
  include Authorizable

  def index
    stats_aggregator = ThermostatReadingAggregator.new(thermostat)

    render json: {
      temperature: stats_aggregator.temperature,
      humidity: stats_aggregator.humidity,
      battery_charge: stats_aggregator.battery_charge
    }, status: 200
  end
end
