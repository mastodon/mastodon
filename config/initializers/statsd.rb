# frozen_string_literal: true

if ENV.key?('STATSD_ADDR')
  statsd_host, _, statsd_port = ENV.fetch('STATSD_ADDR', nil).rpartition(':')
else
  statsd_host = ENV.fetch('STATSD_HOST', nil)
  statsd_port = ENV.fetch('STATSD_PORT', nil)
end

if statsd_host.is_a?(String) && statsd_port.is_a?(String)
  $statsd = ::Statsd.new(statsd_host, statsd_port)
  $statsd.namespace = ENV.fetch('STATSD_NAMESPACE') { ['Mastodon', Rails.env].join('.') }

  ::NSA.inform_statsd($statsd) do |informant|
    informant.collect(:action_controller, :web)
    informant.collect(:active_record, :db)
    informant.collect(:active_support_cache, :cache)
    informant.collect(:sidekiq, :sidekiq)
  end
end
