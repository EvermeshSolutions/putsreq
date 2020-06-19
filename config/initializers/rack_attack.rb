class PutsReqThrottle
  class << self
    def enable
      throttle_by_bucket
      throttle_by_ip
      throttled_response
    end

    private

    DEFAULT_LIMIT = ENV.fetch('THROTTLE_LIMIT', 45)
    DEFAULT_PERIOD = ENV.fetch('THROTTLE_PERIOD', 60)

    def requests_count_path?(path)
      path.end_with?('/requests_count')
    end

    def throttle_by_bucket
      Rack::Attack.throttle('requests by bucket (path) ', limit: DEFAULT_LIMIT, period: DEFAULT_PERIOD) do |request|
        request.path unless requests_count_path?(request.path)
      end
    end

    def throttle_by_ip
      Rack::Attack.throttle('requests by ip', limit: DEFAULT_LIMIT, period: DEFAULT_PERIOD) do |request|
        request.ip unless requests_count_path?(request.path)
      end
    end

    def throttled_response
      Rack::Attack.throttled_response = lambda do |env|
        match_data = env['rack.attack.match_data']
        now = match_data[:epoch_time]

        headers = {
          'RateLimit-Limit' => match_data[:limit].to_s,
          'RateLimit-Remaining' => '0',
          'RateLimit-Reset' => (now + (match_data[:period] - now % match_data[:period])).to_s
        }

        [429, headers, ['Your requests are being temporally throttled. Please contact for increasing your limits.\n']]
      end
    end
  end
end

PutsReqThrottle.enable if ENV['ENABLE_THROTTLE']
