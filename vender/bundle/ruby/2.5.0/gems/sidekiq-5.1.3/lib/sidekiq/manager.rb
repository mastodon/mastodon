# frozen_string_literal: true
require 'sidekiq/util'
require 'sidekiq/processor'
require 'sidekiq/fetch'
require 'thread'
require 'set'

module Sidekiq

  ##
  # The Manager is the central coordination point in Sidekiq, controlling
  # the lifecycle of the Processors.
  #
  # Tasks:
  #
  # 1. start: Spin up Processors.
  # 3. processor_died: Handle job failure, throw away Processor, create new one.
  # 4. quiet: shutdown idle Processors.
  # 5. stop: hard stop the Processors by deadline.
  #
  # Note that only the last task requires its own Thread since it has to monitor
  # the shutdown process.  The other tasks are performed by other threads.
  #
  class Manager
    include Util

    attr_reader :workers
    attr_reader :options

    def initialize(options={})
      logger.debug { options.inspect }
      @options = options
      @count = options[:concurrency] || 25
      raise ArgumentError, "Concurrency of #{@count} is not supported" if @count < 1

      @done = false
      @workers = Set.new
      @count.times do
        @workers << Processor.new(self)
      end
      @plock = Mutex.new
    end

    def start
      @workers.each do |x|
        x.start
      end
    end

    def quiet
      return if @done
      @done = true

      logger.info { "Terminating quiet workers" }
      @workers.each { |x| x.terminate }
      fire_event(:quiet, reverse: true)
    end

    # hack for quicker development / testing environment #2774
    PAUSE_TIME = STDOUT.tty? ? 0.1 : 0.5

    def stop(deadline)
      quiet
      fire_event(:shutdown, reverse: true)

      # some of the shutdown events can be async,
      # we don't have any way to know when they're done but
      # give them a little time to take effect
      sleep PAUSE_TIME
      return if @workers.empty?

      logger.info { "Pausing to allow workers to finish..." }
      remaining = deadline - Time.now
      while remaining > PAUSE_TIME
        return if @workers.empty?
        sleep PAUSE_TIME
        remaining = deadline - Time.now
      end
      return if @workers.empty?

      hard_shutdown
    end

    def processor_stopped(processor)
      @plock.synchronize do
        @workers.delete(processor)
      end
    end

    def processor_died(processor, reason)
      @plock.synchronize do
        @workers.delete(processor)
        unless @done
          p = Processor.new(self)
          @workers << p
          p.start
        end
      end
    end

    def stopped?
      @done
    end

    private

    def hard_shutdown
      # We've reached the timeout and we still have busy workers.
      # They must die but their jobs shall live on.
      cleanup = nil
      @plock.synchronize do
        cleanup = @workers.dup
      end

      if cleanup.size > 0
        jobs = cleanup.map {|p| p.job }.compact

        logger.warn { "Terminating #{cleanup.size} busy worker threads" }
        logger.warn { "Work still in progress #{jobs.inspect}" }

        # Re-enqueue unfinished jobs
        # NOTE: You may notice that we may push a job back to redis before
        # the worker thread is terminated. This is ok because Sidekiq's
        # contract says that jobs are run AT LEAST once. Process termination
        # is delayed until we're certain the jobs are back in Redis because
        # it is worse to lose a job than to run it twice.
        strategy = (@options[:fetch] || Sidekiq::BasicFetch)
        strategy.bulk_requeue(jobs, @options)
      end

      cleanup.each do |processor|
        processor.kill
      end
    end

  end
end
