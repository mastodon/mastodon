require 'json'

require 'sidekiq-scheduler/utils'
require_relative 'redis_manager'

module SidekiqScheduler
  module Schedule

    # Accepts a new schedule configuration of the form:
    #
    #   {
    #     "MakeTea" => {
    #       "every" => "1m" },
    #     "some_name" => {
    #       "cron"        => "5/* * * *",
    #       "class"       => "DoSomeWork",
    #       "args"        => "work on this string",
    #       "description" => "this thing works it"s butter off" },
    #     ...
    #   }
    #
    # Hash keys can be anything and are used to describe and reference
    # the scheduled job. If the "class" argument is missing, the key
    # is used implicitly as "class" argument - in the "MakeTea" example,
    # "MakeTea" is used both as job name and sidekiq worker class.
    #
    # :cron can be any cron scheduling string
    #
    # :every can be used in lieu of :cron. see rufus-scheduler's 'every' usage
    # for valid syntax. If :cron is present it will take precedence over :every.
    #
    # :class must be a sidekiq worker class. If it is missing, the job name (hash key)
    # will be used as :class.
    #
    # :args can be any yaml which will be converted to a ruby literal and
    # passed in a params. (optional)
    #
    # :description is just that, a description of the job (optional). If
    # params is an array, each element in the array is passed as a separate
    # param, otherwise params is passed in as the only parameter to perform.
    def schedule=(schedule_hash)
      schedule_hash = prepare_schedule(schedule_hash)
      to_remove = get_all_schedules.keys - schedule_hash.keys.map(&:to_s)

      schedule_hash.each do |name, job_spec|
        set_schedule(name, job_spec)
      end

      to_remove.each do |name|
        remove_schedule(name)
      end

      @schedule = schedule_hash
    end

    def schedule
      @schedule
    end

    # Reloads the schedule from Redis and return it.
    #
    # @return Hash
    def reload_schedule!
      @schedule = get_schedule
    end
    alias_method :schedule!, :reload_schedule!

    # Retrive the schedule configuration for the given name
    # if the name is nil it returns a hash with all the
    # names end their schedules.
    def get_schedule(name = nil)
      if name.nil?
        get_all_schedules
      else
        encoded_schedule = SidekiqScheduler::RedisManager.get_job_schedule(name)
        encoded_schedule.nil? ? nil : JSON.parse(encoded_schedule)
      end
    end

    # gets the schedule as it exists in redis
    def get_all_schedules
      schedules = {}

      if SidekiqScheduler::RedisManager.schedule_exist?
        SidekiqScheduler::RedisManager.get_all_schedules.tap do |h|
          h.each do |name, config|
            schedules[name] = JSON.parse(config)
          end
        end
      end

      schedules
    end

    # Create or update a schedule with the provided name and configuration.
    #
    # Note: values for class and custom_job_class need to be strings,
    # not constants.
    #
    #    Sidekiq.set_schedule('some_job', { :class => 'SomeJob',
    #                                       :every => '15mins',
    #                                       :queue => 'high',
    #                                       :args => '/tmp/poop' })
    def set_schedule(name, config)
      existing_config = get_schedule(name)
      unless existing_config && existing_config == config
        SidekiqScheduler::RedisManager.set_job_schedule(name, config)
        SidekiqScheduler::RedisManager.add_schedule_change(name)
      end
      config
    end

    # remove a given schedule by name
    def remove_schedule(name)
      SidekiqScheduler::RedisManager.remove_job_schedule(name)
      SidekiqScheduler::RedisManager.add_schedule_change(name)
    end

    private

    def prepare_schedule(schedule_hash)
      schedule_hash = SidekiqScheduler::Utils.stringify_keys(schedule_hash)

      prepared_hash = {}

      schedule_hash.each do |name, job_spec|
        job_spec = job_spec.dup

        job_class = job_spec.fetch('class', name)
        inferred_queue = infer_queue(job_class)

        job_spec['class'] ||= job_class
        job_spec['queue'] ||= inferred_queue unless inferred_queue.nil?

        prepared_hash[name] = job_spec
      end
      prepared_hash
    end

    def infer_queue(klass)
      klass = try_to_constantize(klass)

      if klass.respond_to?(:sidekiq_options)
        klass.sidekiq_options['queue']
      end
    end

    def try_to_constantize(klass)
      klass.is_a?(String) ? klass.constantize : klass
    rescue NameError
      klass
    end
  end
end
