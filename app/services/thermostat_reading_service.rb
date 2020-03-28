class ThermostatReadingService
  
  def initialize(thermostat)
    @thermostat = thermostat
  end

  def create_async(params)
    number = next_sequence_number
    final_params = params.merge({number: number})

    reading_cache.add(number, final_params)
    change_household_count(1)

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
    change_household_count(-1)

    reading
  end

  def reading_cache
    @reading_cache = ReadingCache.new(@thermostat)
  end

  def next_sequence_number
    Reading.
      joins(:thermostat).
      where(thermostats: { household_token: @thermostat.household_token }).
      count + household_count + 1
  end

  private
    def household_count
      reading_cache.get(@thermostat.household_token) || 0
    end
    
    def change_household_count(increment)
      count = reading_cache.get(@thermostat.household_token) || 0
      reading_cache.add(@thermostat.household_token, count + increment)
    end

end
