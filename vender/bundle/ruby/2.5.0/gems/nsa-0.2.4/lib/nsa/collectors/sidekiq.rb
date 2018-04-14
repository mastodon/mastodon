require "nsa/statsd/publisher"

module NSA
  module Collectors
    class Sidekiq
      include ::NSA::Statsd::Publisher

      def self.collect(key_prefix)
        require "sidekiq"

        ::Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add(::NSA::Collectors::Sidekiq, key_prefix)
          end
        end
      rescue ::LoadError => exception
        $stderr.puts("[LoadError] Failed to load sidekiq!", exception.message, *(exception.backtrace))
      end

      attr_accessor :key_prefix
      private :key_prefix=

      def initialize(key_prefix)
        self.key_prefix = key_prefix.to_s.split(".")
      end

      def call(worker, message, queue_name)
        worker_name = worker.class.name.tr("::", ".")

        statsd_time(make_key(worker_name, :processing_time)) do
          yield
        end

        statsd_increment(make_key(worker_name, :success))
      rescue => exception
        statsd_increment(make_key(worker_name, :failure))
        fail exception
      ensure
        publish_overall_stats
        publish_queue_size_and_latency(queue_name)
      end

      private

      def publish_overall_stats
        stats = ::Sidekiq::Stats.new
        statsd_gauge(make_key(:dead_size), stats.dead_size)
        statsd_gauge(make_key(:enqueued), stats.enqueued)
        statsd_gauge(make_key(:failed), stats.failed)
        statsd_gauge(make_key(:processed), stats.processed)
        statsd_gauge(make_key(:processes_size), stats.processes_size)
        statsd_gauge(make_key(:retry_size), stats.retry_size)
        statsd_gauge(make_key(:scheduled_size), stats.scheduled_size)
        statsd_gauge(make_key(:workers_size), stats.workers_size)
      end

      def publish_queue_size_and_latency(queue_name)
        queue = ::Sidekiq::Queue.new(queue_name)
        statsd_gauge(make_key(:queues, queue_name, :enqueued), queue.size)

        if queue.respond_to?(:latency)
          statsd_gauge(make_key(:queues, queue_name, :latency), queue.latency)
        end
      end

      def make_key(*args)
        (key_prefix + args).compact.join(".")
      end

    end
  end
end
