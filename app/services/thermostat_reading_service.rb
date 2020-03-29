class ThermostatReadingService
  
  def initialize(thermostat)
    @thermostat = thermostat
  end

  def find_by_number(number)
    reading_cache.lock do
      reading = @thermostat.readings.find_by(number: number) || find_in_cache(number)
      raise ActiveRecord::RecordNotFound if reading.blank?
      reading
    end
  end

  def create_async(params)
    reading_cache.lock do
      number = next_sequence_number
      final_params = params.merge({number: number})

      reading_cache.add(number, final_params)

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

      reading
    end
  end

  def stats
    reading_cache.lock do
      stats_aggregator = ThermostatReadingAggregator.new(@thermostat)

      {
        temperature: stats_aggregator.temperature,
        humidity: stats_aggregator.humidity,
        battery_charge: stats_aggregator.battery_charge
      }
    end
  end

  def reading_cache
    @reading_cache = ReadingCache.new(@thermostat)
  end

  def cached_readings
    @cached_readings ||= reading_cache.get_all.map { |reading_attr| Reading.new(reading_attr) }
  end

  def next_sequence_number
    saved_readings_total + reading_cache.get_household_count + 1
  end

  private
    def find_in_cache(number)
      cached = reading_cache.get(number)
      Reading.new(cached) if cached.present?
    end

    def saved_readings_total
      Reading.
        joins(:thermostat).
        where(thermostats: { household_token: @thermostat.household_token }).
        count
    end

end
