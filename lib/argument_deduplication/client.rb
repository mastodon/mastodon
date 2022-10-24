# frozen_string_literal: true

module ArgumentDeduplication
  class Client
    include Sidekiq::ClientMiddleware

    def call(_worker, job, _queue, _redis_pool)
      process_arguments!(job)
      yield
    end

    private

    def process_arguments!(job)
      return unless job['deduplicate_arguments']

      argument_index = job['deduplicate_arguments']
      argument       = Argument.from_value(job['args'][argument_index])

      argument.push!

      job['args'][argument_index] = argument.content_hash
    end
  end
end
