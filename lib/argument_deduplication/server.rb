# frozen_string_literal: true

module ArgumentDeduplication
  class Server
    include Sidekiq::ServerMiddleware

    def call(_worker, job, _queue)
      argument = process_argument!(job)

      yield

      # If the job completes successfully, we can remove
      # the argument from the store. If there is an exception,
      # the job will be retried, so we can't remove the argument
      # from the store yet. When retries are exhausted, or when
      # retries are disabled for the worker, the configured death
      # handler will remove it.

      argument&.pop!
    end

    private

    def process_argument!(job)
      return unless job['deduplicate_arguments']

      argument_index = job['deduplicate_arguments']
      content_hash   = job['args'][argument_index]
      value          = Sidekiq.redis { |redis| redis.get("#{PREFIX}:value:#{content_hash}") }

      raise CorruptedArgumentError, "The argument for hash #{content_hash} could not be found" if value.nil?

      job['args'][argument_index] = value

      Argument.new(content_hash, value)
    end
  end
end
