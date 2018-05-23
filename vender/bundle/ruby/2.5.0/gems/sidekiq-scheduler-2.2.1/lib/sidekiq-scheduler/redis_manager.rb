module SidekiqScheduler
  module RedisManager

    REGISTERED_JOBS_THRESHOLD_IN_SECONDS = 24 * 60 * 60

    # Returns the schedule of a given job
    #
    # @param [String] name The name of the job
    #
    # @return [String] schedule in JSON format
    def self.get_job_schedule(name)
      hget(:schedules, name)
    end

    # Returns the state of a given job
    #
    # @param [String] name The name of the job
    #
    # @return [String] state in JSON format
    def self.get_job_state(name)
      hget(schedules_state_key, name)
    end

    # Returns the next execution time for a given job
    #
    # @param [String] name The name of the job
    #
    # @return [String] next time the job has to be executed
    def self.get_job_next_time(name)
      hget(next_times_key, name)
    end

    # Returns the last execution time of a given job
    #
    # @param [String] name The name of the job
    #
    # @return [String] last time the job was executed
    def self.get_job_last_time(name)
      hget(last_times_key, name)
    end

    # Sets the schedule for a given job
    #
    # @param [String] name The name of the job
    # @param [Hash] config The new schedule for the job
    def self.set_job_schedule(name, config)
      hset(:schedules, name, JSON.generate(config))
    end

    # Sets the state for a given job
    #
    # @param [String] name The name of the job
    # @param [Hash] state The new state for the job
    def self.set_job_state(name, state)
      hset(schedules_state_key, name, JSON.generate(state))
    end

    # Sets the next execution time for a given job
    #
    # @param [String] name The name of the job
    # @param [String] next_time The next time the job has to be executed
    def self.set_job_next_time(name, next_time)
      hset(next_times_key, name, next_time)
    end

    # Sets the last execution time for a given job
    #
    # @param [String] name The name of the job
    # @param [String] last_time The last time the job was executed
    def self.set_job_last_time(name, last_time)
      hset(last_times_key, name, last_time)
    end

    # Removes the schedule for a given job
    #
    # @param [String] name The name of the job
    def self.remove_job_schedule(name)
      hdel(:schedules, name)
    end

    # Removes the next execution time for a given job
    #
    # @param [String] name The name of the job
    def self.remove_job_next_time(name)
      hdel(next_times_key, name)
    end

    # Returns the schedules of all the jobs
    #
    # @return [Hash] hash with all the job schedules
    def self.get_all_schedules
      Sidekiq.redis { |r| r.hgetall(:schedules) }
    end

    # Returns boolean value that indicates if the schedules value exists
    #
    # @return [Boolean] true if the schedules key is set, false otherwise
    def self.schedule_exist?
      Sidekiq.redis { |r| r.exists(:schedules) }
    end

    # Returns all the schedule changes for a given time range.
    #
    # @param [Float] from The minimum value in the range
    # @param [Float] to The maximum value in the range
    #
    # @return [Array] array with all the changed job names
    def self.get_schedule_changes(from, to)
      Sidekiq.redis { |r| r.zrangebyscore(:schedules_changed, from, "(#{to}") }
    end

    # Register a schedule change for a given job
    #
    # @param [String] name The name of the job
    def self.add_schedule_change(name)
      Sidekiq.redis { |r| r.zadd(:schedules_changed, Time.now.to_f, name) }
    end

    # Remove all the schedule changes records
    def self.clean_schedules_changed
      Sidekiq.redis { |r| r.del(:schedules_changed) unless r.type(:schedules_changed) == 'zset' }
    end

    # Removes a queued job instance
    #
    # @param [String] job_name The name of the job
    # @param [Time] time The time at which the job was cleared by the scheduler
    #
    # @return [Boolean] true if the job was registered, false otherwise
    def self.register_job_instance(job_name, time)
      job_key = pushed_job_key(job_name)
      registered, _ = Sidekiq.redis do |r|
        r.pipelined do
          r.zadd(job_key, time.to_i, time.to_i)
          r.expire(job_key, REGISTERED_JOBS_THRESHOLD_IN_SECONDS)
        end
      end

      registered
    end

    # Removes instances of the job older than 24 hours
    #
    # @param [String] job_name The name of the job
    def self.remove_elder_job_instances(job_name)
      seconds_ago = Time.now.to_i - REGISTERED_JOBS_THRESHOLD_IN_SECONDS

      Sidekiq.redis do |r|
        r.zremrangebyscore(pushed_job_key(job_name), 0, seconds_ago)
      end
    end

    # Returns the key of the Redis sorted set used to store job enqueues
    #
    # @param [String] job_name The name of the job
    #
    # @return [String] the pushed job key
    def self.pushed_job_key(job_name)
      "sidekiq-scheduler:pushed:#{job_name}"
    end

    # Returns the key of the Redis hash for job's execution times hash
    #
    # @return [String] with the key
    def self.next_times_key
      'sidekiq-scheduler:next_times'
    end

    # Returns the key of the Redis hash for job's last execution times hash
    #
    # @return [String] with the key
    def self.last_times_key
      'sidekiq-scheduler:last_times'
    end

    # Returns the Redis's key for saving schedule states.
    #
    # @return [String] with the key
    def self.schedules_state_key
      'sidekiq-scheduler:states'
    end

    private

    # Returns the value of a Redis stored hash field
    #
    # @param [String] hash_key The key name of the hash
    # @param [String] field_key The key name of the field
    #
    # @return [String]
    def self.hget(hash_key, field_key)
      Sidekiq.redis { |r| r.hget(hash_key, field_key) }
    end

    # Sets the value of a Redis stored hash field
    #
    # @param [String] hash_key The key name of the hash
    # @param [String] field_key The key name of the field
    # @param [String] value The new value name for the field
    def self.hset(hash_key, field_key, value)
      Sidekiq.redis { |r| r.hset(hash_key, field_key, value) }
    end

    # Removes the value of a Redis stored hash field
    #
    # @param [String] hash_key The key name of the hash
    # @param [String] field_key The key name of the field
    def self.hdel(hash_key, field_key)
      Sidekiq.redis { |r| r.hdel(hash_key, field_key) }
    end
  end
end
