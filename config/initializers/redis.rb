class SafeRedis
  def initialize
    @redis = Redis.new url: ENV['REDISTOGO_URL']
  rescue => e
    # Bad URI i.e. URI::InvalidURIError
    Rails.logger.error e
  end

  def method_missing(method, *args, &block)
    @redis.send method, *args, &block
  rescue => e
    # Redis specific exceptions i.e. ECONNREFUSED
    Rails.logger.error e
  end
end

REDIS = SafeRedis.new
