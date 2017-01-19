# frozen_string_literal: true

StatsD.prefix              = 'mastodon'
StatsD.default_sample_rate = 1

StatsDMonitor.extend(StatsD::Instrument)
StatsDMonitor.statsd_measure(:call, 'request.duration')

STATSD_REQUEST_METRICS = {
  'request.status.success'               => 200,
  'request.status.not_found'             => 404,
  'request.status.too_many_requests'     => 429,
  'request.status.internal_server_error' => 500,
}.freeze

STATSD_REQUEST_METRICS.each do |name, code|
  StatsDMonitor.statsd_count_if(:call, name) do |status, _env, _body|
    status.to_i == code
  end
end
