begin
  require 'sidekiq/web/helpers'
rescue LoadError
  require 'sidekiq/web_helpers'
end
require 'sidekiq-scheduler/redis_manager'

module SidekiqScheduler
  class JobPresenter
    attr_reader :name

    include Sidekiq::WebHelpers

    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end

    # Returns the next time execution for the job
    #
    # @return [String] with the job's next time
    def next_time
      execution_time = SidekiqScheduler::RedisManager.get_job_next_time(name)

      relative_time(Time.parse(execution_time)) if execution_time
    end

    # Returns the last execution time for the job
    #
    # @return [String] with the job's last time
    def last_time
      execution_time = SidekiqScheduler::RedisManager.get_job_last_time(name)

      relative_time(Time.parse(execution_time)) if execution_time
    end

    # Returns the interval for the job
    #
    # @return [String] with the job's interval
    def interval
      @attributes['cron'] || @attributes['interval'] || @attributes['every']
    end

    # Returns the queue of the job
    #
    # @return [String] with the job's queue
    def queue
      @attributes.fetch('queue', 'default')
    end

    # Delegates the :[] method to the attributes' hash
    #
    # @return [String] with the value for that key
    def [](key)
      @attributes[key]
    end

    def enabled?
      SidekiqScheduler::Scheduler.job_enabled?(@name)
    end

    # Builds the presenter instances for the schedule hash
    #
    # @param schedule_hash [Hash] with the redis schedule
    # @return [Array<JobPresenter>] an array with the instances of presenters
    def self.build_collection(schedule_hash)
      schedule_hash ||= {}

      schedule_hash.map do |name, job_spec|
        new(name, job_spec)
      end
    end
  end
end
