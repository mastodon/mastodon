# frozen_string_literal: true
require 'sidekiq/client'

module Sidekiq

  ##
  # Include this module in your worker class and you can easily create
  # asynchronous jobs:
  #
  # class HardWorker
  #   include Sidekiq::Worker
  #
  #   def perform(*args)
  #     # do some work
  #   end
  # end
  #
  # Then in your Rails app, you can do this:
  #
  #   HardWorker.perform_async(1, 2, 3)
  #
  # Note that perform_async is a class method, perform is an instance method.
  module Worker
    attr_accessor :jid

    def self.included(base)
      raise ArgumentError, "You cannot include Sidekiq::Worker in an ActiveJob: #{base.name}" if base.ancestors.any? {|c| c.name == 'ActiveJob::Base' }

      base.extend(ClassMethods)
      base.sidekiq_class_attribute :sidekiq_options_hash
      base.sidekiq_class_attribute :sidekiq_retry_in_block
      base.sidekiq_class_attribute :sidekiq_retries_exhausted_block
    end

    def logger
      Sidekiq.logger
    end

    # This helper class encapsulates the set options for `set`, e.g.
    #
    #     SomeWorker.set(queue: 'foo').perform_async(....)
    #
    class Setter
      def initialize(klass, opts)
        @klass = klass
        @opts = opts
      end

      def perform_async(*args)
        @klass.client_push(@opts.merge('args' => args, 'class' => @klass))
      end

      # +interval+ must be a timestamp, numeric or something that acts
      #   numeric (like an activesupport time interval).
      def perform_in(interval, *args)
        int = interval.to_f
        now = Time.now.to_f
        ts = (int < 1_000_000_000 ? now + int : int)

        payload = @opts.merge('class' => @klass, 'args' => args, 'at' => ts)
        # Optimization to enqueue something now that is scheduled to go out now or in the past
        payload.delete('at') if ts <= now
        @klass.client_push(payload)
      end
      alias_method :perform_at, :perform_in
    end

    module ClassMethods

      def delay(*args)
        raise ArgumentError, "Do not call .delay on a Sidekiq::Worker class, call .perform_async"
      end

      def delay_for(*args)
        raise ArgumentError, "Do not call .delay_for on a Sidekiq::Worker class, call .perform_in"
      end

      def delay_until(*args)
        raise ArgumentError, "Do not call .delay_until on a Sidekiq::Worker class, call .perform_at"
      end

      def set(options)
        Setter.new(self, options)
      end

      def perform_async(*args)
        client_push('class' => self, 'args' => args)
      end

      # +interval+ must be a timestamp, numeric or something that acts
      #   numeric (like an activesupport time interval).
      def perform_in(interval, *args)
        int = interval.to_f
        now = Time.now.to_f
        ts = (int < 1_000_000_000 ? now + int : int)

        item = { 'class' => self, 'args' => args, 'at' => ts }

        # Optimization to enqueue something now that is scheduled to go out now or in the past
        item.delete('at') if ts <= now

        client_push(item)
      end
      alias_method :perform_at, :perform_in

      ##
      # Allows customization for this type of Worker.
      # Legal options:
      #
      #   queue - use a named queue for this Worker, default 'default'
      #   retry - enable the RetryJobs middleware for this Worker, *true* to use the default
      #      or *Integer* count
      #   backtrace - whether to save any error backtrace in the retry payload to display in web UI,
      #      can be true, false or an integer number of lines to save, default *false*
      #   pool - use the given Redis connection pool to push this type of job to a given shard.
      #
      # In practice, any option is allowed.  This is the main mechanism to configure the
      # options for a specific job.
      def sidekiq_options(opts={})
        # stringify
        self.sidekiq_options_hash = get_sidekiq_options.merge(Hash[opts.map{|k, v| [k.to_s, v]}])
      end

      def sidekiq_retry_in(&block)
        self.sidekiq_retry_in_block = block
      end

      def sidekiq_retries_exhausted(&block)
        self.sidekiq_retries_exhausted_block = block
      end

      def get_sidekiq_options # :nodoc:
        self.sidekiq_options_hash ||= Sidekiq.default_worker_options
      end

      def client_push(item) # :nodoc:
        pool = Thread.current[:sidekiq_via_pool] || get_sidekiq_options['pool'] || Sidekiq.redis_pool
        # stringify
        item.keys.each do |key|
          item[key.to_s] = item.delete(key)
        end

        Sidekiq::Client.new(pool).push(item)
      end

      def sidekiq_class_attribute(*attrs)
        instance_reader = true
        instance_writer = true

        attrs.each do |name|
          singleton_class.instance_eval do
            undef_method(name) if method_defined?(name) || private_method_defined?(name)
          end
          define_singleton_method(name) { nil }

          ivar = "@#{name}"

          singleton_class.instance_eval do
            m = "#{name}="
            undef_method(m) if method_defined?(m) || private_method_defined?(m)
          end
          define_singleton_method("#{name}=") do |val|
            singleton_class.class_eval do
              undef_method(name) if method_defined?(name) || private_method_defined?(name)
              define_method(name) { val }
            end

            if singleton_class?
              class_eval do
                undef_method(name) if method_defined?(name) || private_method_defined?(name)
                define_method(name) do
                  if instance_variable_defined? ivar
                    instance_variable_get ivar
                  else
                    singleton_class.send name
                  end
                end
              end
            end
            val
          end

          if instance_reader
            undef_method(name) if method_defined?(name) || private_method_defined?(name)
            define_method(name) do
              if instance_variable_defined?(ivar)
                instance_variable_get ivar
              else
                self.class.public_send name
              end
            end
          end

          if instance_writer
            m = "#{name}="
            undef_method(m) if method_defined?(m) || private_method_defined?(m)
            attr_writer name
          end
        end
      end

    end
  end
end
