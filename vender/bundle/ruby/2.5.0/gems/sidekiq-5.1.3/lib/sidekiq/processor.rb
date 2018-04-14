# frozen_string_literal: true
require 'sidekiq/util'
require 'sidekiq/fetch'
require 'sidekiq/job_logger'
require 'sidekiq/job_retry'
require 'thread'
require 'concurrent/map'
require 'concurrent/atomic/atomic_fixnum'

module Sidekiq
  ##
  # The Processor is a standalone thread which:
  #
  # 1. fetches a job from Redis
  # 2. executes the job
  #   a. instantiate the Worker
  #   b. run the middleware chain
  #   c. call #perform
  #
  # A Processor can exit due to shutdown (processor_stopped)
  # or due to an error during job execution (processor_died)
  #
  # If an error occurs in the job execution, the
  # Processor calls the Manager to create a new one
  # to replace itself and exits.
  #
  class Processor

    include Util

    attr_reader :thread
    attr_reader :job

    def initialize(mgr)
      @mgr = mgr
      @down = false
      @done = false
      @job = nil
      @thread = nil
      @strategy = (mgr.options[:fetch] || Sidekiq::BasicFetch).new(mgr.options)
      @reloader = Sidekiq.options[:reloader]
      @logging = (mgr.options[:job_logger] || Sidekiq::JobLogger).new
      @retrier = Sidekiq::JobRetry.new
    end

    def terminate(wait=false)
      @done = true
      return if !@thread
      @thread.value if wait
    end

    def kill(wait=false)
      @done = true
      return if !@thread
      # unlike the other actors, terminate does not wait
      # for the thread to finish because we don't know how
      # long the job will take to finish.  Instead we
      # provide a `kill` method to call after the shutdown
      # timeout passes.
      @thread.raise ::Sidekiq::Shutdown
      @thread.value if wait
    end

    def start
      @thread ||= safe_thread("processor", &method(:run))
    end

    private unless $TESTING

    def run
      begin
        while !@done
          process_one
        end
        @mgr.processor_stopped(self)
      rescue Sidekiq::Shutdown
        @mgr.processor_stopped(self)
      rescue Exception => ex
        @mgr.processor_died(self, ex)
      end
    end

    def process_one
      @job = fetch
      process(@job) if @job
      @job = nil
    end

    def get_one
      begin
        work = @strategy.retrieve_work
        (logger.info { "Redis is online, #{Time.now - @down} sec downtime" }; @down = nil) if @down
        work
      rescue Sidekiq::Shutdown
      rescue => ex
        handle_fetch_exception(ex)
      end
    end

    def fetch
      j = get_one
      if j && @done
        j.requeue
        nil
      else
        j
      end
    end

    def handle_fetch_exception(ex)
      if !@down
        @down = Time.now
        logger.error("Error fetching job: #{ex}")
        handle_exception(ex)
      end
      sleep(1)
      nil
    end

    def dispatch(job_hash, queue)
      # since middleware can mutate the job hash
      # we clone here so we report the original
      # job structure to the Web UI
      pristine = cloned(job_hash)

      Sidekiq::Logging.with_job_hash_context(job_hash) do
        @retrier.global(pristine, queue) do
          @logging.call(job_hash, queue) do
            stats(pristine, queue) do
              # Rails 5 requires a Reloader to wrap code execution.  In order to
              # constantize the worker and instantiate an instance, we have to call
              # the Reloader.  It handles code loading, db connection management, etc.
              # Effectively this block denotes a "unit of work" to Rails.
              @reloader.call do
                klass  = constantize(job_hash['class'])
                worker = klass.new
                worker.jid = job_hash['jid']
                @retrier.local(worker, pristine, queue) do
                  yield worker
                end
              end
            end
          end
        end
      end
    end

    def process(work)
      jobstr = work.job
      queue = work.queue_name

      ack = false
      begin
        # Treat malformed JSON as a special case: job goes straight to the morgue.
        job_hash = nil
        begin
          job_hash = Sidekiq.load_json(jobstr)
        rescue => ex
          handle_exception(ex, { :context => "Invalid JSON for job", :jobstr => jobstr })
          # we can't notify because the job isn't a valid hash payload.
          DeadSet.new.kill(jobstr, notify_failure: false)
          ack = true
          raise
        end

        ack = true
        dispatch(job_hash, queue) do |worker|
          Sidekiq.server_middleware.invoke(worker, job_hash, queue) do
            execute_job(worker, cloned(job_hash['args']))
          end
        end
      rescue Sidekiq::Shutdown
        # Had to force kill this job because it didn't finish
        # within the timeout.  Don't acknowledge the work since
        # we didn't properly finish it.
        ack = false
      rescue Exception => ex
        e = ex.is_a?(::Sidekiq::JobRetry::Skip) && ex.cause ? ex.cause : ex
        handle_exception(e, { :context => "Job raised exception", :job => job_hash, :jobstr => jobstr })
        raise e
      ensure
        work.acknowledge if ack
      end
    end

    def execute_job(worker, cloned_args)
      worker.perform(*cloned_args)
    end

    WORKER_STATE = Concurrent::Map.new
    PROCESSED = Concurrent::AtomicFixnum.new
    FAILURE = Concurrent::AtomicFixnum.new

    def stats(job_hash, queue)
      tid = Sidekiq::Logging.tid
      WORKER_STATE[tid] = {:queue => queue, :payload => job_hash, :run_at => Time.now.to_i }

      begin
        yield
      rescue Exception
        FAILURE.increment
        raise
      ensure
        WORKER_STATE.delete(tid)
        PROCESSED.increment
      end
    end

    # Deep clone the arguments passed to the worker so that if
    # the job fails, what is pushed back onto Redis hasn't
    # been mutated by the worker.
    def cloned(thing)
      Marshal.load(Marshal.dump(thing))
    end

    def constantize(str)
      names = str.split('::')
      names.shift if names.empty? || names.first.empty?

      names.inject(Object) do |constant, name|
        # the false flag limits search for name to under the constant namespace
        #   which mimics Rails' behaviour
        constant.const_defined?(name, false) ? constant.const_get(name, false) : constant.const_missing(name)
      end
    end

  end
end
