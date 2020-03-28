class RedisProvider
  def self.get_instance
    if Rails.env.test?
      Redis.new # Will use FakeRedis
    else
      # This should eventually be in an environment variable
      Redis.new(url: 'redis://localhost:6379') 
    end
  end
end
