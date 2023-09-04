# frozen_string_literal: true

dev_null = Logger.new('/dev/null')

Rails.logger                 = dev_null
ActiveRecord::Base.logger    = dev_null
ActiveJob::Base.logger       = dev_null
HttpLog.configuration.logger = dev_null
Paperclip.options[:log]      = false
Chewy.logger                 = dev_null

module Mastodon
  module CLIHelper
    def dry_run?
      options[:dry_run]
    end

    def create_progress_bar(total = nil)
      ProgressBar.create(total: total, format: '%c/%u |%b%i| %e')
    end

    def reset_connection_pools!
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env].dup.tap { |config| config['pool'] = options[:concurrency] + 1 })
      RedisConfiguration.establish_pool(options[:concurrency])
    end

    def parallelize_with_progress(scope)
      if options[:concurrency] < 1
        say('Cannot run with this concurrency setting, must be at least 1', :red)
        exit(1)
      end

      reset_connection_pools!

      progress  = create_progress_bar(scope.count)
      pool      = Concurrent::FixedThreadPool.new(options[:concurrency])
      total     = Concurrent::AtomicFixnum.new(0)
      aggregate = Concurrent::AtomicFixnum.new(0)

      scope.reorder(nil).find_in_batches do |items|
        futures = []

        items.each do |item|
          futures << Concurrent::Future.execute(executor: pool) do
            begin
              if !progress.total.nil? && progress.progress + 1 > progress.total
                # The number of items has changed between start and now,
                # since there is no good way to predict the final count from
                # here, just change the progress bar to an indeterminate one

                progress.total = nil
              end

              progress.log("Processing #{item.id}") if options[:verbose]

              result = ActiveRecord::Base.connection_pool.with_connection do
                yield(item)
              ensure
                RedisConfiguration.pool.checkin if Thread.current[:redis]
                Thread.current[:redis] = nil
              end

              aggregate.increment(result) if result.is_a?(Integer)
            rescue => e
              progress.log pastel.red("Error processing #{item.id}: #{e}")
            ensure
              progress.increment
            end
          end
        end

        total.increment(items.size)
        futures.map(&:value)
      end

      progress.stop

      [total.value, aggregate.value]
    end

    def pastel
      @pastel ||= Pastel.new
    end
  end
end
