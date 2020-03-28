class ReadingPersister
  include Sidekiq::Worker

  def perform(thermostat_id, params)
    # With more time, this could pull from Redis cache as well, instead
    # of holding a second copy of params to persist
    thermostat = Thermostat.find(thermostat_id)
    parsed_params = JSON.parse(params, object_class: HashWithIndifferentAccess)
    ThermostatReadingService.new(thermostat).create(parsed_params)
  end
end
