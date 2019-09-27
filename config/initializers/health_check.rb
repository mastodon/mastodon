HealthCheck.setup do |config|
  config.uri = 'health'

  config.standard_checks = %w(database migrations cache)
  config.full_checks = %w(database migrations cache)
  
  config.include_error_in_response_body = false
end
