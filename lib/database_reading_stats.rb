class DatabaseReadingStats

  def initialize(thermostat)
    @thermostat = thermostat
  end

  def sum(attribute)
    readings.send("#{attribute.to_s}_sum")
  end

  def min(attribute)
    readings.send("#{attribute.to_s}_min")
  end

  def max(attribute)
    readings.send("#{attribute.to_s}_max")
  end

  def total
    readings.total
  end

  def any?
    @thermostat.readings.any?
  end

  private
    def readings
      @readings ||= @thermostat.readings.order(nil).select("
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

end
