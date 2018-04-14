# frozen_string_literal: true

module SidekiqUniqueJobs
  module Server
    class Middleware
      extend Forwardable
      def_delegators :Sidekiq, :logger
      def_instance_delegator :@worker, :class, :worker_class

      include OptionsWithFallback

      def call(worker, item, queue, redis_pool = nil, &blk)
        @worker = worker
        @redis_pool = redis_pool
        @queue = queue
        @item = item
        return yield unless unique_enabled?
        lock.send(:execute, after_unlock_hook, &blk)
      end

      private

      attr_reader :redis_pool, :worker, :item

      protected

      def after_unlock_hook
        -> { worker.after_unlock if worker.respond_to?(:after_unlock) }
      end

      def reschedule
        Sidekiq::Client.new(redis_pool).raw_push([item])
      end
    end
  end
end
