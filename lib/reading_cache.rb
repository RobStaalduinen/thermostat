class ReadingCache

  def initialize(thermostat)
    @thermostat = thermostat
  end

  def add(reading_number, value)
    redis.set(key_name(reading_number), value.to_json)
  end

  def get(reading_number)
    parse_result(
      redis.get(key_name(reading_number))
    )
  end

  def get_all
    redis.keys(key_name('*')).map { |key|
      parse_result(redis.get(key))
    }.compact
  end

  def remove(reading_number)
    redis.del(key_name(reading_number))
  end

  def get_household_count
    redis.get(@thermostat.household_token).to_i || 0
  end

  def set_household_count(new_count)
    redis.set(@thermostat.household_token, new_count.to_i)
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

    def parse_result(result)
      JSON.parse(result, object_class: HashWithIndifferentAccess) if result.present?
    end

    def key_name(matcher)
      "#{@thermostat.id}-#{matcher}"
    end

end
