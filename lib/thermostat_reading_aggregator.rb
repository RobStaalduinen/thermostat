class ThermostatReadingAggregator
  
  def initialize(thermostat)
    @database_readings = DatabaseReadingStats.new(thermostat)
    @cached_readings = CachedReadingStats.new(thermostat)
  end

  def temperature
    attribute_stats(:temperature)
  end

  def humidity
    attribute_stats(:humidity)
  end

  def battery_charge
    attribute_stats(:battery_charge)
  end

  def attribute_stats(attribute)
    return default_results unless has_readings? 
    {
      average: average_for_attribute(attribute),
      min: min_for_attribute(attribute),
      max: max_for_attribute(attribute)
    }
  end

  def average_for_attribute(attribute)
    database_sum = @database_readings.sum(attribute)
    cached_sum = @cached_readings.sum(attribute)
    total = @database_readings.total + @cached_readings.total

    return (database_sum + cached_sum) / total
  end

  def min_for_attribute(attribute)
    [
      @database_readings.min(attribute),
      @cached_readings.min(attribute)
    ].compact.min
  end

  def max_for_attribute(attribute)
    [
      @database_readings.max(attribute),
      @cached_readings.max(attribute)
    ].compact.max
  end

  def has_readings?
    @database_readings.any? || @cached_readings.any?
  end

  def default_results
    { average: 0, min: 0, max: 0}
  end

end
