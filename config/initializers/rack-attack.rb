class Rack::Attack
  throttle('get-req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip if req.get?
  end

  throttle('post-req/ip', limit: 100, period: 5.minutes) do |req|
    req.ip if req.post?
  end
end
