class SafeRedis
  def initialize
    @redis = Redis.new url: ENV['REDIS_URL']
  rescue => ex
    # Bad URI i.e. URI::InvalidURIError
    Rails.logger.error(ex)
  end

  def method_missing(method, *args, &block)
    @redis.send(method, *args, &block)
  rescue => ex
    # Redis specific exceptions i.e. ECONNREFUSED
    Rails.logger.error(ex)
    nil
  end
end

REDIS = SafeRedis.new
