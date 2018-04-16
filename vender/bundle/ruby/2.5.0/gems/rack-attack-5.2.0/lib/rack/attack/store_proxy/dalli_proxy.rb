require 'delegate'

module Rack
  class Attack
    module StoreProxy
      class DalliProxy < SimpleDelegator
        def self.handle?(store)
          return false unless defined?(::Dalli)

          # Consider extracting to a separate Connection Pool proxy to reduce
          # code here and handle clients other than Dalli.
          if defined?(::ConnectionPool) && store.is_a?(::ConnectionPool)
            store.with { |conn| conn.is_a?(::Dalli::Client) }
          else
            store.is_a?(::Dalli::Client)
          end
        end

        def initialize(client)
          super(client)
          stub_with_if_missing
        end

        def read(key)
          with do |client|
            client.get(key)
          end
        rescue Dalli::DalliError
        end

        def write(key, value, options={})
          with do |client|
            client.set(key, value, options.fetch(:expires_in, 0), raw: true)
          end
        rescue Dalli::DalliError
        end

        def increment(key, amount, options={})
          with do |client|
            client.incr(key, amount, options.fetch(:expires_in, 0), amount)
          end
        rescue Dalli::DalliError
        end

        def delete(key)
          with do |client|
            client.delete(key)
          end
        rescue Dalli::DalliError
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
