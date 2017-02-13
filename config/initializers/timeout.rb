if Rails.env.production?
  Rack::Timeout.service_timeout = 90
  Rack::Timeout::Logger.disable
end
