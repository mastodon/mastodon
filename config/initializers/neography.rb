Neography.configure do |config|
  config.protocol             = "http"
  config.server               = ENV.fetch('NEO4J_HOST') { 'localhost' }
  config.port                 = ENV.fetch('NEO4J_PORT') { 7474 }
end
