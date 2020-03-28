class StatsController < ApplicationController
  include Authorizable

  def index
    # Currently not in O(1) time
    # In O(n) time related to the amount of cached readings
    # Can achieve O(1) be precalculating cached min, max and avg
    # on insert and removal of reading from cach

    stats_aggregator = ThermostatReadingAggregator.new(thermostat)

    render json: {
      temperature: stats_aggregator.temperature,
      humidity: stats_aggregator.humidity,
      battery_charge: stats_aggregator.battery_charge
    }, status: 200
  end
end
