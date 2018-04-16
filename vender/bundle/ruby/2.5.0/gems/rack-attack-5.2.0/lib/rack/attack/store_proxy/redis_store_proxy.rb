require 'delegate'

module Rack
  class Attack
    module StoreProxy
      class RedisStoreProxy < SimpleDelegator
        def self.handle?(store)
          # Using const_defined? for now.
          #
          # Go back to use defined? once this ruby issue is
          # fixed and released:
          # https://bugs.ruby-lang.org/issues/14407
          #
          # defined?(::Redis::Store) && store.is_a?(::Redis::Store)
          const_defined?("::Redis::Store") && store.is_a?(::Redis::Store)
        end

        def initialize(store)
          super(store)
        end

        def read(key)
          get(key, raw: true)
        rescue Redis::BaseError
        end

        def write(key, value, options={})
          if (expires_in = options[:expires_in])
            setex(key, expires_in, value, raw: true)
          else
            set(key, value, raw: true)
          end
        rescue Redis::BaseError
        end

        def increment(key, amount, options={})
          count = nil

          pipelined do
            count = incrby(key, amount)
            expire(key, options[:expires_in]) if options[:expires_in]
          end

          count.value if count
        rescue Redis::BaseError
        end

        def delete(key, options={})
          del(key)
        rescue Redis::BaseError
        end
      end
    end
  end
end
