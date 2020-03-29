class StatsController < ApplicationController
  include Authorizable

  def index
    # Currently not in O(1) time
    # In O(n) time related to the amount of cached readings
    # Can achieve O(1) be precalculating cached min, max and avg
    # on insert and removal of reading from cache

    render json: thermostat_service.stats, status: 200
  end

  private
    def thermostat_service
      @service ||= ThermostatReadingService.new(@thermostat)
    end

end
