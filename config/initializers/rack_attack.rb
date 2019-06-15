Rack::Attack.throttle('requests by bucket (path) ', limit: 45, period: 60, &:path)
Rack::Attack.throttle('requests by ip', limit: 45, period: 60, &:ip)