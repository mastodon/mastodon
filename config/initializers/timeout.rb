if Rails.env.production?
  Rack::Timeout.service_timeout = 15
  Rack::Timeout::Logger.disable
end
