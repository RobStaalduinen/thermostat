class ThermostatReadingService
  
  def initialize(thermostat)
    @thermostat = thermostat
  end

  def find_by_number(number)
    reading_cache.lock do
      reading = @thermostat.readings.find_by(number: number) || find_in_cache(number)

      # Should probably be a custom exception, not ActiveRecord
      raise ActiveRecord::RecordNotFound if reading.blank?
      reading.data
    end
  end

  def create_async(params)
    reading_cache.lock do
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
  end

  def create(params)
    reading_cache.lock do
      reading = @thermostat.readings.create(params)
      reading_cache.remove(params[:number])
      change_household_count(-1)

      reading
    end
  end

  def reading_cache
    @reading_cache = ReadingCache.new(@thermostat)
  end

  def cached_readings
    @cached_stats ||= reading_cache.get_all.map { |reading_attr| Reading.new(reading_attr) }
  end

  def next_sequence_number
    Reading.
      joins(:thermostat).
      where(thermostats: { household_token: @thermostat.household_token }).
      count + reading_cache.get_household_count + 1
  end

  private
    def find_in_cache(number)
      cached = reading_cache.get(number)
      Reading.new(cached) if cached.present?
    end
    
    def change_household_count(increment)
      count = reading_cache.get_household_count
      reading_cache.set_household_count(count + increment)
    end

end
