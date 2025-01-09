# frozen_string_literal: true

require 'stoplight'

Rails.application.reloader.to_prepare do
  Stoplight.default_data_store = Stoplight::DataStore::Redis.new(RedisConnection.new.connection)
  Stoplight.default_notifiers  = [Stoplight::Notifier::Logger.new(Rails.logger)]
end
