Rack::Attack.throttle("requests by bucket (path) ", limit: 5, period: 60) do |request|
  request.path
end

Rack::Attack.throttle("requests by ip", limit: 30, period: 60) do |request|
  request.ip
end