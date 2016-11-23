require 'rack-mini-profiler'

Rack::MiniProfilerRails.initialize!(Rails.application)

Rails.application.middleware.swap(Rack::Deflater, Rack::MiniProfiler)
Rails.application.middleware.swap(Rack::MiniProfiler, Rack::Deflater)

Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore

if Rails.env.production?
  Rack::MiniProfiler.config.storage_options = {
    host: ENV.fetch('REDIS_HOST') { 'localhost' },
    port: ENV.fetch('REDIS_PORT') { 6379 },
  }

  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end
