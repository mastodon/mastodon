require 'stoplight'

Stoplight::Light.default_data_store = Stoplight::DataStore::Redis.new(Redis.current)
