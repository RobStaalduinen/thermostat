class CachedReadingStats

  def initialize(thermostat)
    @thermostat = thermostat
  end

  def sum(attribute)
    cached_readings.map { |reading| reading.send(attribute.to_s) }.sum
  end

  def min(attribute)
    cached_readings.map { |reading| reading.send(attribute.to_s) }.min
  end

  def max(attribute)
    cached_readings.map { |reading| reading.send(attribute.to_s) }.max
  end

  def total
    cached_readings.count
  end

  def any?
    total > 0
  end

  private
    def cached_readings
      @cached_readings ||= ThermostatReadingService.new(@thermostat).cached_readings
    end
end
