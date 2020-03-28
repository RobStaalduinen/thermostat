class ThermostatReadingAggregator
  
  def initialize(thermostat)
    @thermostat = thermostat
  end

  def temperature
    return default_results unless has_readings?
    {
      average: reading_results.temperature_sum / reading_results.total,
      min: reading_results.temperature_min,
      max: reading_results.temperature_max
    }
  end

  def humidity
    return default_results unless has_readings?
    {
      average: reading_results.humidity_sum / reading_results.total,
      min: reading_results.humidity_min,
      max: reading_results.humidity_max
    }
  end

  def battery_charge
    return default_results unless has_readings?
    {
      average: reading_results.battery_charge_sum / reading_results.total,
      min: reading_results.battery_charge_min,
      max: reading_results.battery_charge_max
    }
  end

  def has_readings?
    @thermostat.readings.any?
  end

  def reading_results
    @results ||= @thermostat.readings.reorder(nil).select("
      SUM(temperature) as temperature_sum,
      MAX(temperature) as temperature_max,
      MIN(temperature) as temperature_min,
      SUM(humidity) as humidity_sum,
      MAX(humidity) as humidity_max,
      MIN(humidity) as humidity_min,
      SUM(battery_charge) as battery_charge_sum,
      MAX(battery_charge) as battery_charge_max,
      MIN(battery_charge) as battery_charge_min,
      COUNT(distinct id) as total
    ").first
  end

  def default_results
    { average: 0, min: 0, max: 0}
  end

end
