Rack::Attack.cache.store = REDIS

Rack::Attack.throttle("requests by ip", limit: 60, period: 60) do |request|
  request.ip
end