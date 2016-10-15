Neography.configure do |config|
  config.protocol             = "http"
  config.server               = ENV['NEO4J_HOST'] || 'localhost'
  config.port                 = ENV['NEO4J_PORT'] || 7474
end
