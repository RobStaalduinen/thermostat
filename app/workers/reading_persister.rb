class ReadingPersister
  include Sidekiq::Worker

  def perform(thermostat_id, params)
    thermostat = Thermostat.find(thermostat_id)
    parsed_params = JSON.parse(params)
    thermostat.readings.create(parsed_params)
  end
end
