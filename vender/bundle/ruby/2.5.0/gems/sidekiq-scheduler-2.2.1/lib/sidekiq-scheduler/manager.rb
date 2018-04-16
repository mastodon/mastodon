require 'redis'

require 'sidekiq/util'

require 'sidekiq-scheduler/schedule'
require 'sidekiq-scheduler/scheduler'

module SidekiqScheduler

  # The delayed job router in the system.  This
  # manages the scheduled jobs pushed messages
  # from Redis onto the work queues
  #
  class Manager
    include Sidekiq::Util

    def initialize(options)
      SidekiqScheduler::Scheduler.enabled = options[:enabled]
      SidekiqScheduler::Scheduler.dynamic = options[:dynamic]
      SidekiqScheduler::Scheduler.dynamic_every = options[:dynamic_every]
      SidekiqScheduler::Scheduler.listened_queues_only = options[:listened_queues_only]
      Sidekiq.schedule = options[:schedule] if SidekiqScheduler::Scheduler.enabled
    end

    def stop
      SidekiqScheduler::Scheduler.clear_schedule!
    end

    def start
      SidekiqScheduler::Scheduler.load_schedule!
    end

    def reset
      clear_scheduled_work
    end

  end

end
