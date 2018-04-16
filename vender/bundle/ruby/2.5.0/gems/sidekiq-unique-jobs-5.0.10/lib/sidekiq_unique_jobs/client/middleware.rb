# frozen_string_literal: true

require 'sidekiq_unique_jobs/server/middleware'

module SidekiqUniqueJobs
  module Client
    class Middleware
      extend Forwardable
      def_delegators :SidekiqUniqueJobs, :connection, :config, :worker_class_constantize
      def_delegators :Sidekiq, :logger

      include OptionsWithFallback

      def call(worker_class, item, queue, redis_pool = nil)
        @worker_class = worker_class_constantize(worker_class)
        @item = item
        @queue = queue
        @redis_pool = redis_pool

        yield if disabled_or_successfully_locked?
      end

      private

      attr_reader :item, :worker_class, :redis_pool, :queue

      def disabled_or_successfully_locked?
        unique_disabled? || acquire_lock
      end

      def acquire_lock
        return true unless lock.respond_to?(:lock)
        locked = lock.lock(:client)
        warn_about_duplicate(item) unless locked
        locked
      end

      def warn_about_duplicate(item)
        logger.warn "payload is not unique #{item}" if log_duplicate_payload?
      end
    end
  end
end
