class SafeRedis
  def initialize
    uri = URI.parse ENV['REDISTOGO_URL']
    @redis = Redis.new url: ENV['REDISTOGO_URL']
  rescue => e
    # bad URI(is not URI?):  (URI::InvalidURIError)
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
