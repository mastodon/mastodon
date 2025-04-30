# frozen_string_literal: true

if ENV['REDIS_NAMESPACE']
  es_configured = ENV['ES_ENABLED'] == 'true' || ENV.fetch('ES_HOST', 'localhost') != 'localhost' || ENV.fetch('ES_PORT', '9200') != '9200' || ENV.fetch('ES_PASS', 'password') != 'password'

  warn <<~MESSAGE
    WARNING: the REDIS_NAMESPACE environment variable is deprecated and will be removed in Mastodon 4.4.0.

    Please see documentation at https://github.com/mastodon/redis_namespace_migration
  MESSAGE

  warn <<~MESSAGE if es_configured && !ENV['ES_PREFIX']

    In addition, as REDIS_NAMESPACE is being used as a prefix for Elasticsearch, please do not forget to set ES_PREFIX to "#{ENV.fetch('REDIS_NAMESPACE')}".
  MESSAGE
end
