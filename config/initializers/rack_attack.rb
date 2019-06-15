def requests_count_path?(path)
  path.end_with?('/requests_count')
end

Rack::Attack.throttle('requests by bucket (path) ', limit: 45, period: 60) do |request|
  request.path unless requests_count_path?(request.path)
end

Rack::Attack.throttle('requests by ip', limit: 45, period: 60) do |request|
  request.ip unless requests_count_path?(request.path)
end