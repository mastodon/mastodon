# encoding: UTF-8
require 'redis-store'

module ActiveSupport
  module Cache
    class RedisStore < Store

      ERRORS_TO_RESCUE = [
        Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH,
        Redis::CannotConnectError,
        Redis::ConnectionError
      ].freeze

      attr_reader :data

      # Instantiate the store.
      #
      # Example:
      #   RedisStore.new
      #     # => host: localhost,   port: 6379,  db: 0
      #
      #   RedisStore.new "example.com"
      #     # => host: example.com, port: 6379,  db: 0
      #
      #   RedisStore.new "example.com:23682"
      #     # => host: example.com, port: 23682, db: 0
      #
      #   RedisStore.new "example.com:23682/1"
      #     # => host: example.com, port: 23682, db: 1
      #
      #   RedisStore.new "example.com:23682/1/theplaylist"
      #     # => host: example.com, port: 23682, db: 1, namespace: theplaylist
      #
      #   RedisStore.new "localhost:6379/0", "localhost:6380/0"
      #     # => instantiate a cluster
      #
      #   RedisStore.new "localhost:6379/0", "localhost:6380/0", pool_size: 5, pool_timeout: 10
      #     # => use a ConnectionPool
      #
      #   RedisStore.new "localhost:6379/0", "localhost:6380/0",
      #     pool: ::ConnectionPool.new(size: 1, timeout: 1) { ::Redis::Store::Factory.create("localhost:6379/0") })
      #     # => supply an existing connection pool (e.g. for use with redis-sentinel or redis-failover)
      def initialize(*addresses)
        @options = addresses.dup.extract_options!
        addresses = addresses.map(&:dup)

        @data = if @options[:pool]
                  raise "pool must be an instance of ConnectionPool" unless @options[:pool].is_a?(ConnectionPool)
                  @pooled = true
                  @options[:pool]
                elsif [:pool_size, :pool_timeout].any? { |key| @options.has_key?(key) }
                  pool_options           = {}
                  pool_options[:size]    = options[:pool_size] if options[:pool_size]
                  pool_options[:timeout] = options[:pool_timeout] if options[:pool_timeout]
                  @pooled = true
                  ::ConnectionPool.new(pool_options) { ::Redis::Store::Factory.create(*addresses) }
                else
                  ::Redis::Store::Factory.create(*addresses)
                end

        super(@options)
      end

      def write(name, value, options = nil)
        options = merged_options(options)
        instrument(:write, name, options) do |payload|
          entry = options[:raw].present? ? value : Entry.new(value, options)
          if options[:expires_in].present? && options[:race_condition_ttl].present? && options[:raw].blank?
            options[:expires_in] = options[:expires_in].to_f + options[:race_condition_ttl].to_f
          end
          write_entry(normalize_key(name, options), entry, options)
        end
      end

      # Delete objects for matched keys.
      #
      # Performance note: this operation can be dangerous for large production
      # databases, as it uses the Redis "KEYS" command, which is O(N) over the
      # total number of keys in the database. Users of large Redis caches should
      # avoid this method.
      #
      # Example:
      #   cache.delete_matched "rab*"
      def delete_matched(matcher, options = nil)
        options = merged_options(options)
        instrument(:delete_matched, matcher.inspect) do
          matcher = key_matcher(matcher, options)
          begin
            with do |store|
              !(keys = store.keys(matcher)).empty? && store.del(*keys)
            end
          rescue *ERRORS_TO_RESCUE
            raise if raise_errors?
            false
          end
        end
      end

      # Reads multiple keys from the cache using a single call to the
      # servers for all keys. Options can be passed in the last argument.
      #
      # Example:
      #   cache.read_multi "rabbit", "white-rabbit"
      #   cache.read_multi "rabbit", "white-rabbit", :raw => true
      def read_multi(*names)
        options = names.extract_options!
        return {} if names == []

        keys = names.map{|name| normalize_key(name, options)}
        args = [keys, options]
        args.flatten!

        instrument(:read_multi, names) do |payload|
          values = with { |c| c.mget(*args) }
          values.map! { |v| v.is_a?(ActiveSupport::Cache::Entry) ? v.value : v }

          Hash[names.zip(values)].reject{|k,v| v.nil?}.tap do |result|
            payload[:hits] = result.keys if payload
          end
        end
      rescue *ERRORS_TO_RESCUE
        raise if raise_errors?
        {}
      end

      def fetch_multi(*names)
        options = names.extract_options!
        return {} if names == []

        results = read_multi(*names, options)
        need_writes = {}

        fetched = names.inject({}) do |memo, name|
          memo[name] = results.fetch(name) do
            value = yield name
            need_writes[name] = value
            value
          end

          memo
        end

        begin
          with do |c|
            c.multi do
              need_writes.each do |name, value|
                write(name, value, options)
              end
            end
          end
        rescue *ERRORS_TO_RESCUE
          raise if raise_errors?
        end

        fetched
      end

      # Increment a key in the store.
      #
      # If the key doesn't exist it will be initialized on 0.
      # If the key exist but it isn't a Fixnum it will be initialized on 0.
      #
      # Example:
      #   We have two objects in cache:
      #     counter # => 23
      #     rabbit  # => #<Rabbit:0x5eee6c>
      #
      #   cache.increment "counter"
      #   cache.read "counter", :raw => true      # => "24"
      #
      #   cache.increment "counter", 6
      #   cache.read "counter", :raw => true      # => "30"
      #
      #   cache.increment "a counter"
      #   cache.read "a counter", :raw => true    # => "1"
      #
      #   cache.increment "rabbit"
      #   cache.read "rabbit", :raw => true       # => "1"
      def increment(key, amount = 1, options = {})
        options = merged_options(options)
        instrument(:increment, key, :amount => amount) do
          with{|c| c.incrby normalize_key(key, options), amount}
        end
      end

      # Decrement a key in the store
      #
      # If the key doesn't exist it will be initialized on 0.
      # If the key exist but it isn't a Fixnum it will be initialized on 0.
      #
      # Example:
      #   We have two objects in cache:
      #     counter # => 23
      #     rabbit  # => #<Rabbit:0x5eee6c>
      #
      #   cache.decrement "counter"
      #   cache.read "counter", :raw => true      # => "22"
      #
      #   cache.decrement "counter", 2
      #   cache.read "counter", :raw => true      # => "20"
      #
      #   cache.decrement "a counter"
      #   cache.read "a counter", :raw => true    # => "-1"
      #
      #   cache.decrement "rabbit"
      #   cache.read "rabbit", :raw => true       # => "-1"
      def decrement(key, amount = 1, options = {})
        options = merged_options(options)
        instrument(:decrement, key, :amount => amount) do
          with{|c| c.decrby normalize_key(key, options), amount}
        end
      end

      def expire(key, ttl)
        options = merged_options(nil)
        with { |c| c.expire normalize_key(key, options), ttl }
      end

      # Clear all the data from the store.
      def clear
        instrument(:clear, nil, nil) do
          with(&:flushdb)
        end
      end

      # fixed problem with invalid exists? method
      # https://github.com/rails/rails/commit/cad2c8f5791d5bd4af0f240d96e00bae76eabd2f
      def exist?(name, options = nil)
        res = super(name, options)
        res || false
      end

      def stats
        with(&:info)
      end

      def with(&block)
        if defined?(@pooled) && @pooled
          @data.with(&block)
        else
          block.call(@data)
        end
      end

      def reconnect
        @data.reconnect if @data.respond_to?(:reconnect)
      end

      protected
        def write_entry(key, entry, options)
          method = options && options[:unless_exist] ? :setnx : :set
          with { |client| client.send method, key, entry, options }
        rescue *ERRORS_TO_RESCUE
          raise if raise_errors?
          false
        end

        def read_entry(key, options)
          entry = with { |c| c.get key, options }
          if entry
            entry.is_a?(ActiveSupport::Cache::Entry) ? entry : ActiveSupport::Cache::Entry.new(entry)
          end
        rescue *ERRORS_TO_RESCUE
          raise if raise_errors?
          nil
        end

        ##
        # Implement the ActiveSupport::Cache#delete_entry
        #
        # It's really needed and use
        #
        def delete_entry(key, options)
          with { |c| c.del key }
        rescue *ERRORS_TO_RESCUE
          raise if raise_errors?
          false
        end

        def raise_errors?
          !!@options[:raise_errors]
        end

        # Add the namespace defined in the options to a pattern designed to match keys.
        #
        # This implementation is __different__ than ActiveSupport:
        # __it doesn't accept Regular expressions__, because the Redis matcher is designed
        # only for strings with wildcards.
        def key_matcher(pattern, options)
          prefix = options[:namespace].is_a?(Proc) ? options[:namespace].call : options[:namespace]

          pattern = pattern.inspect[1..-2] if pattern.is_a? Regexp

          if prefix
            "#{prefix}:#{pattern}"
          else
            pattern
          end
        end

      private

        if ActiveSupport::VERSION::MAJOR < 5
          def normalize_key(*args)
            namespaced_key(*args)
          end
        end
    end
  end
end
