def requests_count_path?(path)
  path.end_with?('/requests_count')
end

Rack::Attack.throttle('requests by bucket (path) ', limit: 45, period: 60) do |request|
  request.path unless requests_count_path?(request.path)
end

Rack::Attack.throttle('requests by ip', limit: 45, period: 60) do |request|
  request.ip unless requests_count_path?(request.path)
end

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
