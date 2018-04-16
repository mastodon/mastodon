module Rack
  class Attack
    module StoreProxy
      PROXIES = [DalliProxy, MemCacheProxy, RedisStoreProxy].freeze

      ACTIVE_SUPPORT_WRAPPER_CLASSES = Set.new(['ActiveSupport::Cache::MemCacheStore', 'ActiveSupport::Cache::RedisStore']).freeze
      ACTIVE_SUPPORT_CLIENTS = Set.new(['Redis::Store', 'Dalli::Client', 'MemCache']).freeze

      def self.build(store)
        client = unwrap_active_support_stores(store)
        klass = PROXIES.find { |proxy| proxy.handle?(client) }
        klass ? klass.new(client) : client
      end


      private
      def self.unwrap_active_support_stores(store)
        # ActiveSupport::Cache::RedisStore doesn't expose any way to set an expiry,
        # so use the raw Redis::Store instead.
        # We also want to use the underlying Dalli client instead of ::ActiveSupport::Cache::MemCacheStore,
        # and the MemCache client if using Rails 3.x

        if store.instance_variable_defined?(:@data)
          client = store.instance_variable_get(:@data)
        end

        if ACTIVE_SUPPORT_WRAPPER_CLASSES.include?(store.class.to_s) && ACTIVE_SUPPORT_CLIENTS.include?(client.class.to_s)
          client
        else
          store
        end
      end
    end
  end
end
