# frozen_string_literal: true

# This is greatly based on the sidekiq-worker-killer gem
# https://github.com/klaxit/sidekiq-worker-killer/

# Copyright (c) 2018-present KLAXIT SAS
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

module Sidekiq::Middleware::Server
  # Sidekiq server middleware. Kill worker when the number of used
  # Resolv::DNS::RequestID allocations grows too big.
  # See https://bugs.ruby-lang.org/issues/17781
  class ResolvWorkaround
    include Sidekiq::Util

    MUTEX = Mutex.new

    # @param [Hash] options
    # @option options [Integer] min_remaining_ids
    #   Number of remaining allocatable RequestID under which shutdown will be
    #   triggered. (default: `500`)
    # @option options [Integer] grace_time
    #   When shutdown is triggered, the Sidekiq process will not accept new job
    #   and wait at most 15 minutes for running jobs to finish.
    #   If Float::INFINITY is specified, will wait forever. (default: `900`)
    # @option options [Integer] shutdown_wait
    #   when the grace time expires, still running jobs get 30 seconds to
    #   stop. After that, kill signal is triggered. (default: `30`)
    # @option options [String] kill_signal
    #   Signal to use to kill Sidekiq process if it doesn't stop.
    #   (default: `"SIGKILL"`)
    # @option options [Proc] skip_shutdown_if
    #   Executes a block of code after max_rss exceeds but before requesting
    #   shutdown. (default: `proc {false}`)
    def initialize(options = {})
      @max_allocated   = 65536 - options.fetch(:min_remaining_ids, 500)
      @grace_time      = options.fetch(:grace_time, 15 * 60)
      @shutdown_wait   = options.fetch(:shutdown_wait, 30)
      @kill_signal     = options.fetch(:kill_signal, "SIGKILL")
      @skip_shutdown   = options.fetch(:skip_shutdown_if, proc { false })
    end

    # @param [String, Class] worker_class
    #   the string or class of the worker class being enqueued
    # @param [Hash] job
    #   the full job payload
    #   @see https://github.com/mperham/sidekiq/wiki/Job-Format
    # @param [String] queue
    #   the name of the queue the job was pulled from
    # @yield the next middleware in the chain or the enqueuing of the job
    def call(worker, job, queue)
      yield

      allocated_ids = Resolv::DNS::RequestID.values.first&.count
      return if allocated_ids.nil? || allocated_ids < @max_allocated

      if skip_shutdown?(worker, job, queue)
        warn "current allocated RequestIDs #{allocated_ids} exceeds maximum #{@max_allocated}, " \
             "however shutdown will be ignored"
        return
      end

      warn "current allocated RequestIDs #{allocated_ids} of #{identity} exceeds " \
           "maximum #{@max_allocated}"
      request_shutdown
    end

    private

    def skip_shutdown?(worker, job, queue)
      @skip_shutdown.respond_to?(:call) && @skip_shutdown.call(worker, job, queue)
    end

    def request_shutdown
      # In another thread to allow undelying job to finish
      Thread.new do
        # Only if another thread is not already
        # shutting down the Sidekiq process
        shutdown if MUTEX.try_lock
      end
    end

    def shutdown
      warn "sending quiet to #{identity}"
      sidekiq_process.quiet!

      sleep(5) # gives Sidekiq API 5 seconds to update ProcessSet

      warn "shutting down #{identity} in #{@grace_time} seconds"
      wait_job_finish_in_grace_time

      warn "stopping #{identity}"
      sidekiq_process.stop!

      warn "waiting #{@shutdown_wait} seconds before sending " \
            "#{@kill_signal} to #{identity}"
      sleep(@shutdown_wait)

      warn "sending #{@kill_signal} to #{identity}"
      ::Process.kill(@kill_signal, ::Process.pid)
    end

    def wait_job_finish_in_grace_time
      start = Time.now
      sleep(1) until grace_time_exceeded?(start) || jobs_finished?
    end

    def grace_time_exceeded?(start)
      return false if @grace_time == Float::INFINITY

      start + @grace_time < Time.now
    end

    def jobs_finished?
      sidekiq_process.stopping? && sidekiq_process["busy"] == 0
    end

    def current_rss
      ::GetProcessMem.new.mb
    end

    def sidekiq_process
      Sidekiq::ProcessSet.new.find do |process|
        process["identity"] == identity
      end || raise("No sidekiq worker with identity #{identity} found")
    end

    def warn(msg)
      Sidekiq.logger.warn(msg)
    end
  end
end
