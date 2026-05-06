# frozen_string_literal: true

if ENV['REDIS_NAMESPACE']
  es_configured = ENV['ES_ENABLED'] == 'true' || ENV.fetch('ES_HOST', 'localhost') != 'localhost' || ENV.fetch('ES_PORT', '9200') != '9200' || ENV.fetch('ES_PASS', 'password') != 'password'

  message = <<~MESSAGE
    ERROR: the REDIS_NAMESPACE environment variable is no longer supported, and a migration is required.

    Please see documentation at https://github.com/mastodon/redis_namespace_migration
  MESSAGE

  message += <<~MESSAGE if es_configured && !ENV['ES_PREFIX']

    In addition, as REDIS_NAMESPACE is being used as a prefix for Elasticsearch, please do not forget to set ES_PREFIX to "#{ENV.fetch('REDIS_NAMESPACE')}".
  MESSAGE

  abort message # rubocop:disable Rails/Exit
end

if ENV.key?('WHITELIST_MODE')
  warn(<<~MESSAGE.squish)
    WARNING: The environment variable WHITELIST_MODE has been replaced with
    LIMITED_FEDERATION_MODE. Please update your configuration.
  MESSAGE
end
