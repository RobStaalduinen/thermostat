class ThermostatReadingService
  
  def initialize(thermostat)
    @thermostat = thermostat
  end

  def create_async(params)
    number = next_sequence_number
    final_params = params.merge({number: number})

    reading_cache.add(number, final_params)
    ReadingPersister.perform_async(
      @thermostat.id,
      final_params.to_json
    )

    number
  end

  def create(params)
    number = params[:number]
    reading = @thermostat.readings.create(params)
    reading_cache.remove(number)

    reading
  end

  def reading_cache
    @reading_cache = ReadingCache.new(@thermostat)
  end

  private
    def next_sequence_number
      Reading.
        joins(:thermostat).
        where(thermostats: { household_token: @thermostat.household_token }).
        count + 1
    end

end
