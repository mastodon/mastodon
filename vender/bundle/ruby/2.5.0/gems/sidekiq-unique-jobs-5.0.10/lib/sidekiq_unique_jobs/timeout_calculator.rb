# frozen_string_literal: true

module SidekiqUniqueJobs
  class TimeoutCalculator
    def self.for_item(item)
      new(item)
    end

    def initialize(item)
      @item = item
    end

    def time_until_scheduled
      scheduled = item[AT_KEY]
      return 0 unless scheduled
      (Time.at(scheduled) - Time.now.utc).to_i
    end

    def seconds
      raise NotImplementedError
    end

    def worker_class_queue_lock_expiration
      worker_class_expiration_for QUEUE_LOCK_TIMEOUT_KEY
    end

    def worker_class_run_lock_expiration
      worker_class_expiration_for RUN_LOCK_TIMEOUT_KEY
    end

    def worker_class
      @worker_class ||= SidekiqUniqueJobs.worker_class_constantize(item[CLASS_KEY])
    end

    private

    def worker_class_expiration_for(key)
      return unless worker_class.respond_to?(:get_sidekiq_options)
      worker_class.get_sidekiq_options[key]
    end

    attr_reader :item
  end

  class RunLockTimeoutCalculator < TimeoutCalculator
    def seconds
      @seconds ||= (
        worker_class_run_lock_expiration ||
        SidekiqUniqueJobs.config.default_run_lock_expiration
      ).to_i
    end
  end

  class QueueLockTimeoutCalculator < TimeoutCalculator
    def seconds
      queue_lock_expiration + time_until_scheduled
    end

    def queue_lock_expiration
      @queue_lock_expiration ||=
        (
          worker_class_queue_lock_expiration ||
          SidekiqUniqueJobs.config.default_queue_lock_expiration
        ).to_i
    end
  end
end
