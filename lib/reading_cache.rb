class ReadingCache

  def initialize(thermostat)
    @thermostat = thermostat
  end

  def add(reading_number, value)
    redis.set("#{@thermostat.id}-#{reading_number}", value.to_json)
  end

  def get(reading_number)
    result = redis.get("#{@thermostat.id}-#{reading_number}")
    return nil unless result
    JSON.parse(
      result,
      object_class: HashWithIndifferentAccess
    )
  end

  def remove(reading_number)
    redis.del("#{@thermostat.id}-#{reading_number}")
  end

  private

    def redis
      @redis_instance ||= RedisProvider.get_instance
    end

end
