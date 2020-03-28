class ThermostatReadingAggregator
  
  def initialize(thermostat)
    @thermostat = thermostat
  end

  def temperature
    attribute_stats('temperature')
  end

  def humidity
    attribute_stats('humidity')
  end

  def battery_charge
    attribute_stats('battery_charge')
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
    database_sum = reading_results.send("#{attribute}_sum") || 0
    cached_sum = cached_readings.map { |reading| reading.send(attribute) }.sum
    total = (reading_results.total || 0) + cached_readings.size

    return (database_sum + cached_sum) / total
  end

  def min_for_attribute(attribute)
    [
      reading_results.send("#{attribute}_min"),
      cached_readings.map { |reading| reading.send(attribute) }.min
    ].compact.min
  end

  def max_for_attribute(attribute)
    [
      reading_results.send("#{attribute}_max"),
      cached_readings.map { |reading| reading.send(attribute) }.max
    ].compact.max
  end

  def has_readings?
    @thermostat.readings.any? || cached_readings.any?
  end

  def cached_readings
    @cached_readings = ThermostatReadingService.new(@thermostat).cached_readings
  end

  def reading_results
    @results ||= @thermostat.readings.order(nil).select("
      SUM(temperature) as temperature_sum,
      MAX(temperature) as temperature_max,
      MIN(temperature) as temperature_min,
      SUM(humidity) as humidity_sum,
      MAX(humidity) as humidity_max,
      MIN(humidity) as humidity_min,
      SUM(battery_charge) as battery_charge_sum,
      MAX(battery_charge) as battery_charge_max,
      MIN(battery_charge) as battery_charge_min,
      COUNT(DISTINCT id) as total
    ").first
  end

  def default_results
    { average: 0, min: 0, max: 0}
  end

end
