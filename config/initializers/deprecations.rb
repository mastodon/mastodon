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

  abort message
end

if ENV['MASTODON_USE_LIBVIPS'] == 'false'
  warn <<~MESSAGE
    WARNING: Mastodon support for ImageMagick is deprecated and will be removed in future versions. Please consider using libvips instead.
  MESSAGE
end
