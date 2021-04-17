# frozen_string_literal: true

namespace    = ENV.fetch('REDIS_NAMESPACE') { nil }
redis_params = { url: ENV['REDIS_URL'] }

if namespace
  redis_params[:namespace] = namespace
end

Sidekiq.configure_server do |config|
  config.redis = redis_params

  config.server_middleware do |chain|
    chain.add SidekiqErrorHandler
  end

  config.death_handlers << lambda do |job, _ex|
    digest = job['lock_digest']
    SidekiqUniqueJobs::Digests.delete_by_digest(digest) if digest
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_params
end

Sidekiq.logger.level = ::Logger.const_get(ENV.fetch('RAILS_LOG_LEVEL', 'info').upcase.to_s)
