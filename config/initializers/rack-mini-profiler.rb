Rails.application.middleware.swap(Rack::Deflater, Rack::MiniProfiler)
Rails.application.middleware.swap(Rack::MiniProfiler, Rack::Deflater)
