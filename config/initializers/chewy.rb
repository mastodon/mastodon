# frozen_string_literal: true

search_config = Rails.configuration.x.search

Chewy.settings = {
  host: search_config.host,
  prefix: search_config.prefix,
  enabled: search_config.enabled,
  journal: false,
  user: search_config.user,
  password: search_config.password,
  index: {
    number_of_replicas: search_config.preset == 'single_node_cluster' ? 0 : 1,
  },
  transport_options: search_config.ca_file.present? ? { ssl: { ca_file: search_config.ca_file } } : nil,
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
