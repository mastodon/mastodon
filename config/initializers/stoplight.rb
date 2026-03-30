# frozen_string_literal: true

require 'stoplight'

Rails.application.reloader.to_prepare do
  Stoplight.configure do |config|
    config.data_store = Stoplight::DataStore::Redis.new(RedisConnection.new.connection)
    config.notifiers = [Stoplight::Notifier::Logger.new(Rails.logger)]
  end
end
