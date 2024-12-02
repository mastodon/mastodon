# frozen_string_literal: true

dev_null = Logger.new('/dev/null')

Rails.logger                 = dev_null
ActiveRecord::Base.logger    = dev_null
ActiveJob::Base.logger       = dev_null
HttpLog.configuration.logger = dev_null if defined?(HttpLog)
Paperclip.options[:log]      = false
Chewy.logger                 = dev_null

require 'ruby-progressbar/outputs/null'

module Mastodon::CLI
  module ProgressHelper
    PROGRESS_FORMAT = '%c/%u |%b%i| %e'

    def create_progress_bar(total = nil)
      ProgressBar.create(
        {
          total: total,
          format: PROGRESS_FORMAT,
        }.merge(progress_output_options)
      )
    end

    def parallelize_with_progress(scope)
      fail_with_message 'Cannot run with this concurrency setting, must be at least 1' if options[:concurrency] < 1

      reset_connection_pools!

      progress  = create_progress_bar(scope.count)
      pool      = Concurrent::FixedThreadPool.new(options[:concurrency])
      total     = Concurrent::AtomicFixnum.new(0)
      aggregate = Concurrent::AtomicFixnum.new(0)

      scope.reorder(nil).find_in_batches do |items|
        futures = items.map do |item|
          Concurrent::Future.execute(executor: pool) do
            if !progress.total.nil? && progress.progress + 1 > progress.total
              # The number of items has changed between start and now,
              # since there is no good way to predict the final count from
              # here, just change the progress bar to an indeterminate one

              progress.total = nil
            end

            progress.log("Processing #{item.id}") if options[:verbose]

            Chewy.strategy(:mastodon) do
              result = ActiveRecord::Base.connection_pool.with_connection do
                yield(item)
              ensure
                RedisConnection.pool.checkin if Thread.current[:redis]
                Thread.current[:redis] = nil
              end

              aggregate.increment(result) if result.is_a?(Integer)
            end
          rescue => e
            progress.log pastel.red("Error processing #{item.id}: #{e}")
          ensure
            progress.increment
          end
        end

        total.increment(items.size)
        futures.map(&:value)
      end

      progress.stop

      [total.value, aggregate.value]
    end

    private

    def progress_output_options
      Rails.env.test? ? { output: ProgressBar::Outputs::Null } : {}
    end
  end
end
