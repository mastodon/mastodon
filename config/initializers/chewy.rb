# frozen_string_literal: true

Chewy.settings = {
  host: "#{Rails.configuration.x.search.host}:#{Rails.configuration.x.search.port}",
  prefix: Rails.configuration.x.search.prefix,
  enabled: Rails.configuration.x.search.enabled,
  journal: false,
  user: Rails.configuration.x.search.user,
  password: Rails.configuration.x.search.password,
  index: {
    number_of_replicas: ['single_node_cluster', nil].include?(Rails.configuration.x.search.preset) ? 0 : 1,
  },
  transport_options: { ssl: { ca_file: Rails.configuration.x.search.ca_file }.compact.presence }.compact.presence,
}

# We use our own async strategy even outside the request-response
# cycle, which takes care of checking if Elasticsearch is enabled
# or not. However, mind that for the Rails console, the :urgent
# strategy is set automatically with no way to override it.
Chewy.root_strategy              = :bypass_with_warning if Rails.env.production?
Chewy.request_strategy           = :mastodon
Chewy.use_after_commit_callbacks = false

# Elasticsearch uses Faraday internally. Faraday interprets the
# http_proxy env variable by default which leads to issues when
# Mastodon is run with hidden services enabled, because
# Elasticsearch is *not* supposed to be accessed through a proxy
Faraday.ignore_env_proxy = true
