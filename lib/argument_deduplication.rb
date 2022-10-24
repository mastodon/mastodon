# frozen_string_literal: true

require_relative './argument_deduplication/argument'
require_relative './argument_deduplication/server'
require_relative './argument_deduplication/client'

module ArgumentDeduplication
  class CorruptedArgumentError < ::RuntimeError; end

  PREFIX = 'argument_store'

  # The time-to-live is based on the maximum amount of time
  # a job can possibly spend in the retry queue, assuming
  # the exponential backoff algorithm and a maximum number
  # of 16 retries. It is intended as a safe-guard against
  # any arguments being orphaned due to interruptions.
  TTL = 50.days.to_i

  DEATH_HANDLER = ->(job) {
    Argument.new(job['args'][job['deduplicate_arguments']]).pop! if job['deduplicate_arguments']
  }.freeze

  def self.configure(config)
    config.death_handlers << DEATH_HANDLER
  end
end
