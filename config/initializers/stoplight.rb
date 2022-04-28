require 'stoplight'

Stoplight::Light.default_data_store = Stoplight::DataStore::Redis.new(RedisConfiguration.new.connection)
Stoplight::Light.default_notifiers  = [Stoplight::Notifier::Logger.new(Rails.logger)]
