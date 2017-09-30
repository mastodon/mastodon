Rack::Timeout::Logger.disable
Rack::Timeout.service_timeout = false

if Rails.env.production?
  Rack::Timeout.service_timeout = 90
end
