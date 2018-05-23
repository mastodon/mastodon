module Rack
  class Attack
    module StoreProxy
      class MemCacheProxy < SimpleDelegator
        def self.handle?(store)
          defined?(::MemCache) && store.is_a?(::MemCache)
        end

        def initialize(store)
          super(store)
          stub_with_if_missing
        end

        def read(key)
          # Second argument: reading raw value
          get(key, true)
          rescue MemCache::MemCacheError
        end

        def write(key, value, options={})
          # Third argument: writing raw value
          set(key, value, options.fetch(:expires_in, 0), true)
        rescue MemCache::MemCacheError
        end

        def increment(key, amount, options={})
          incr(key, amount)
        rescue MemCache::MemCacheError
        end

        def delete(key, options={})
          with do |client|
            client.delete(key)
          end
        rescue MemCache::MemCacheError
        end

        private

        def stub_with_if_missing
          unless __getobj__.respond_to?(:with)
            class << self
              def with; yield __getobj__; end
            end
          end
        end

      end
    end
  end
end
