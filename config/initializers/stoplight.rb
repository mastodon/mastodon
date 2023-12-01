# frozen_string_literal: true

require 'stoplight'

Rails.application.reloader.to_prepare do
  Stoplight::Light.default_data_store = Stoplight::DataStore::Redis.new(RedisConfiguration.new.connection)
  Stoplight::Light.default_notifiers  = [Stoplight::Notifier::Logger.new(Rails.logger)]
end
