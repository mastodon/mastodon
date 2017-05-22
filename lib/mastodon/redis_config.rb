# frozen_string_literal: true

if ENV['REDIS_URL'].blank?
  password = ENV.fetch('REDIS_PASSWORD') { '' }
  host     = ENV.fetch('REDIS_HOST') { 'localhost' }
  port     = ENV.fetch('REDIS_PORT') { 6379 }
  db       = ENV.fetch('REDIS_DB') { 0 }

  ENV['REDIS_URL'] = "redis://#{password.blank? ? '' : ":#{password}@"}#{host}:#{port}/#{db}"
end

REDIS_CACHE_PARAMS = {
  expires_in: 10.minutes,
  namespace: 'cache'
}

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }
REDIS_CACHE_PARAMS[:namespace] = namespace + '_cache' if namespace
