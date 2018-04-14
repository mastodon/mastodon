# frozen_string_literal: true
require 'sidekiq/scheduled'
require 'sidekiq/api'

module Sidekiq
  ##
  # Automatically retry jobs that fail in Sidekiq.
  # Sidekiq's retry support assumes a typical development lifecycle:
  #
  #   0. Push some code changes with a bug in it.
  #   1. Bug causes job processing to fail, Sidekiq's middleware captures
  #      the job and pushes it onto a retry queue.
  #   2. Sidekiq retries jobs in the retry queue multiple times with
  #      an exponential delay, the job continues to fail.
  #   3. After a few days, a developer deploys a fix. The job is
  #      reprocessed successfully.
  #   4. Once retries are exhausted, Sidekiq will give up and move the
  #      job to the Dead Job Queue (aka morgue) where it must be dealt with
  #      manually in the Web UI.
  #   5. After 6 months on the DJQ, Sidekiq will discard the job.
  #
  # A job looks like:
  #
  #     { 'class' => 'HardWorker', 'args' => [1, 2, 'foo'], 'retry' => true }
  #
  # The 'retry' option also accepts a number (in place of 'true'):
  #
  #     { 'class' => 'HardWorker', 'args' => [1, 2, 'foo'], 'retry' => 5 }
  #
  # The job will be retried this number of times before giving up. (If simply
  # 'true', Sidekiq retries 25 times)
  #
  # We'll add a bit more data to the job to support retries:
  #
  #  * 'queue' - the queue to use
  #  * 'retry_count' - number of times we've retried so far.
  #  * 'error_message' - the message from the exception
  #  * 'error_class' - the exception class
  #  * 'failed_at' - the first time it failed
  #  * 'retried_at' - the last time it was retried
  #  * 'backtrace' - the number of lines of error backtrace to store
  #
  # We don't store the backtrace by default as that can add a lot of overhead
  # to the job and everyone is using an error service, right?
  #
  # The default number of retries is 25 which works out to about 3 weeks
  # You can change the default maximum number of retries in your initializer:
  #
  #   Sidekiq.options[:max_retries] = 7
  #
  # or limit the number of retries for a particular worker with:
  #
  #    class MyWorker
  #      include Sidekiq::Worker
  #      sidekiq_options :retry => 10
  #    end
  #
  class JobRetry
    class Skip < ::RuntimeError; end

    include Sidekiq::Util

    DEFAULT_MAX_RETRY_ATTEMPTS = 25

    def initialize(options = {})
      @max_retries = Sidekiq.options.merge(options).fetch(:max_retries, DEFAULT_MAX_RETRY_ATTEMPTS)
    end

    # The global retry handler requires only the barest of data.
    # We want to be able to retry as much as possible so we don't
    # require the worker to be instantiated.
    def global(msg, queue)
      yield
    rescue Skip => ex
      raise ex
    rescue Sidekiq::Shutdown => ey
      # ignore, will be pushed back onto queue during hard_shutdown
      raise ey
    rescue Exception => e
      # ignore, will be pushed back onto queue during hard_shutdown
      raise Sidekiq::Shutdown if exception_caused_by_shutdown?(e)

      raise e unless msg['retry']
      attempt_retry(nil, msg, queue, e)
      raise e
    end


    # The local retry support means that any errors that occur within
    # this block can be associated with the given worker instance.
    # This is required to support the `sidekiq_retries_exhausted` block.
    #
    # Note that any exception from the block is wrapped in the Skip
    # exception so the global block does not reprocess the error.  The
    # Skip exception is unwrapped within Sidekiq::Processor#process before
    # calling the handle_exception handlers.
    def local(worker, msg, queue)
      yield
    rescue Skip => ex
      raise ex
    rescue Sidekiq::Shutdown => ey
      # ignore, will be pushed back onto queue during hard_shutdown
      raise ey
    rescue Exception => e
      # ignore, will be pushed back onto queue during hard_shutdown
      raise Sidekiq::Shutdown if exception_caused_by_shutdown?(e)

      if msg['retry'] == nil
        msg['retry'] = worker.class.get_sidekiq_options['retry']
      end

      raise e unless msg['retry']
      attempt_retry(worker, msg, queue, e)
      # We've handled this error associated with this job, don't
      # need to handle it at the global level
      raise Skip
    end

    private

    # Note that +worker+ can be nil here if an error is raised before we can
    # instantiate the worker instance.  All access must be guarded and
    # best effort.
    def attempt_retry(worker, msg, queue, exception)
      max_retry_attempts = retry_attempts_from(msg['retry'], @max_retries)

      msg['queue'] = if msg['retry_queue']
        msg['retry_queue']
      else
        queue
      end

      # App code can stuff all sorts of crazy binary data into the error message
      # that won't convert to JSON.
      m = exception.message.to_s[0, 10_000]
      if m.respond_to?(:scrub!)
        m.force_encoding("utf-8")
        m.scrub!
      end

      msg['error_message'] = m
      msg['error_class'] = exception.class.name
      count = if msg['retry_count']
        msg['retried_at'] = Time.now.to_f
        msg['retry_count'] += 1
      else
        msg['failed_at'] = Time.now.to_f
        msg['retry_count'] = 0
      end

      if msg['backtrace'] == true
        msg['error_backtrace'] = exception.backtrace
      elsif !msg['backtrace']
        # do nothing
      elsif msg['backtrace'].to_i != 0
        msg['error_backtrace'] = exception.backtrace[0...msg['backtrace'].to_i]
      end

      if count < max_retry_attempts
        delay = delay_for(worker, count, exception)
        logger.debug { "Failure! Retry #{count} in #{delay} seconds" }
        retry_at = Time.now.to_f + delay
        payload = Sidekiq.dump_json(msg)
        Sidekiq.redis do |conn|
          conn.zadd('retry', retry_at.to_s, payload)
        end
      else
        # Goodbye dear message, you (re)tried your best I'm sure.
        retries_exhausted(worker, msg, exception)
      end
    end

    def retries_exhausted(worker, msg, exception)
      logger.debug { "Retries exhausted for job" }
      begin
        block = worker && worker.sidekiq_retries_exhausted_block
        block.call(msg, exception) if block
      rescue => e
        handle_exception(e, { context: "Error calling retries_exhausted", job: msg })
      end

      Sidekiq.death_handlers.each do |handler|
        begin
          handler.call(msg, exception)
        rescue => e
          handle_exception(e, { context: "Error calling death handler", job: msg })
        end
      end

      send_to_morgue(msg) unless msg['dead'] == false
    end

    def send_to_morgue(msg)
      Sidekiq.logger.info { "Adding dead #{msg['class']} job #{msg['jid']}" }
      payload = Sidekiq.dump_json(msg)
      DeadSet.new.kill(payload, notify_failure: false)
    end

    def retry_attempts_from(msg_retry, default)
      if msg_retry.is_a?(Integer)
        msg_retry
      else
        default
      end
    end

    def delay_for(worker, count, exception)
      if worker && worker.sidekiq_retry_in_block
        custom_retry_in = retry_in(worker, count, exception).to_i
        return custom_retry_in if custom_retry_in > 0
      end
      seconds_to_delay(count)
    end

    # delayed_job uses the same basic formula
    def seconds_to_delay(count)
      (count ** 4) + 15 + (rand(30)*(count+1))
    end

    def retry_in(worker, count, exception)
      begin
        worker.sidekiq_retry_in_block.call(count, exception)
      rescue Exception => e
        handle_exception(e, { context: "Failure scheduling retry using the defined `sidekiq_retry_in` in #{worker.class.name}, falling back to default" })
        nil
      end
    end

    def exception_caused_by_shutdown?(e, checked_causes = [])
      return false unless e.cause

      # Handle circular causes
      checked_causes << e.object_id
      return false if checked_causes.include?(e.cause.object_id)

      e.cause.instance_of?(Sidekiq::Shutdown) ||
        exception_caused_by_shutdown?(e.cause, checked_causes)
    end

  end
end
