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

  def lock
    # Locking to the thermostat isn't exactly ideal here, as it requires a database connection.
    # A better solution would be a distributed Redis lock, such as Redlock
    # https://github.com/leandromoreira/redlock-rb
    @thermostat.with_lock do
      yield
    end
  end

  private

    def redis
      @redis_instance ||= RedisProvider.get_instance
    end

end
