require 'sidekiq-scheduler/utils'

module SidekiqScheduler
  class RufusUtils

    # Normalizes schedule options to rufust scheduler options
    #
    # @param options [String, [Array]
    #
    # @return [Array]
    #
    # @example
    #   normalize_schedule_options('15m') => ['15m', {}]
    #   normalize_schedule_options(['15m']) => ['15m', {}]
    #   normalize_schedule_options(['15m', first_in: '5m']) => ['15m', { first_in: '5m' }]
    def self.normalize_schedule_options(options)
      schedule, opts = options

      if !opts.is_a?(Hash)
        opts = {}
      end

      opts = SidekiqScheduler::Utils.symbolize_keys(opts)

      return schedule, opts
    end
  end
end

