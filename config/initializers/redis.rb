# frozen_string_literal: true

redis_config = if ENV['REDIS_SOCKET']
  { path: ENV['REDIS_SOCKET'] }
else
  { 
    host: ENV.fetch('REDIS_HOST') { 'localhost' }, 
    port: ENV.fetch('REDIS_PORT') { 6379 },
    password: ENV.fetch('REDIS_PASSWORD') { false },
  }
end

redis_config[:driver] = :hiredis

Redis.current = Redis.new(redis_config)
