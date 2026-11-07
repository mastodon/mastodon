# frozen_string_literal: true

require 'stoplight'

Rails.application.reloader.to_prepare do
  Stoplight.configure do |config|
    config.data_store = Stoplight::DataStore::Redis.new(RedisConnection.new.connection)
    config.notifiers = [Stoplight::Notifier::Logger.new(Rails.logger)]
  end

  Stoplight.register(
    'api:donation_campaigns',
    cool_off_time: 60,
    threshold: 10
  )

  Stoplight.register(
    'storage:object',
    cool_off_time: 30,
    threshold: 10,
    tracked_errors: [Seahorse::Client::NetworkingError]
  )

  Stoplight.register(
    'search:elasticsearch',
    cool_off_time: 5.minutes.seconds,
    threshold: 10,
    tracked_errors: [Faraday::ConnectionFailed, Errno::ENETUNREACH, OpenSSL::SSL::SSLError, Elastic::Transport::Transport::Error]
  )
end
