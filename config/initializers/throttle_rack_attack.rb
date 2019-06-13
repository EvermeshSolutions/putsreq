Rack::Attack.cache.store = REDIS

Rack::Attack.throttle("requests by bucket (path) ", limit: 30, period: 60) do |request|
  request.path
end

Rack::Attack.throttle("requests by ip", limit: 30, period: 60) do |request|
  request.ip
end