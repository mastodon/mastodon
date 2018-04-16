require 'sidekiq'
require 'tilt/erb'

require_relative 'sidekiq/scheduler'
require_relative 'sidekiq-scheduler/version'
require_relative 'sidekiq-scheduler/manager'
require_relative 'sidekiq-scheduler/redis_manager'
require_relative 'sidekiq-scheduler/extensions/schedule'

Sidekiq.configure_server do |config|

  config.on(:startup) do
    dynamic = Sidekiq::Scheduler.dynamic
    dynamic = dynamic.nil? ? config.options.fetch(:dynamic, false) : dynamic

    dynamic_every = Sidekiq::Scheduler.dynamic_every
    dynamic_every = dynamic_every.nil? ? config.options.fetch(:dynamic_every, '5s') : dynamic_every

    enabled = Sidekiq::Scheduler.enabled
    enabled = enabled.nil? ? config.options.fetch(:enabled, true) : enabled

    scheduler = config.options.fetch(:scheduler, {})

    listened_queues_only = Sidekiq::Scheduler.listened_queues_only
    listened_queues_only = listened_queues_only.nil? ? scheduler[:listened_queues_only] : listened_queues_only

    schedule = Sidekiq.schedule
    schedule ||= config.options[:schedule] || {}

    scheduler_options = {
      dynamic:       dynamic,
      dynamic_every: dynamic_every,
      enabled:       enabled,
      schedule:      schedule,
      listened_queues_only: listened_queues_only
    }

    # schedules_changed's type was changed from SET to ZSET, so we remove old versions at startup
    SidekiqScheduler::RedisManager.clean_schedules_changed

    schedule_manager = SidekiqScheduler::Manager.new(scheduler_options)
    config.options[:schedule_manager] = schedule_manager
    config.options[:schedule_manager].start
  end

  config.on(:shutdown) do
    config.options[:schedule_manager].stop
  end

end
