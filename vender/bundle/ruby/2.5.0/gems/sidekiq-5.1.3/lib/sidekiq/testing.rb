# frozen_string_literal: true
require 'securerandom'
require 'sidekiq'

module Sidekiq

  class Testing
    class << self
      attr_accessor :__test_mode

      def __set_test_mode(mode)
        if block_given?
          current_mode = self.__test_mode
          begin
            self.__test_mode = mode
            yield
          ensure
            self.__test_mode = current_mode
          end
        else
          self.__test_mode = mode
        end
      end

      def disable!(&block)
        __set_test_mode(:disable, &block)
      end

      def fake!(&block)
        __set_test_mode(:fake, &block)
      end

      def inline!(&block)
        __set_test_mode(:inline, &block)
      end

      def enabled?
        self.__test_mode != :disable
      end

      def disabled?
        self.__test_mode == :disable
      end

      def fake?
        self.__test_mode == :fake
      end

      def inline?
        self.__test_mode == :inline
      end

      def server_middleware
        @server_chain ||= Middleware::Chain.new
        yield @server_chain if block_given?
        @server_chain
      end

      def constantize(str)
        names = str.split('::')
        names.shift if names.empty? || names.first.empty?

        names.inject(Object) do |constant, name|
          constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
      end
    end
  end

  # Default to fake testing to keep old behavior
  Sidekiq::Testing.fake!

  class EmptyQueueError < RuntimeError; end

  class Client
    alias_method :raw_push_real, :raw_push

    def raw_push(payloads)
      if Sidekiq::Testing.fake?
        payloads.each do |job|
          job = Sidekiq.load_json(Sidekiq.dump_json(job))
          job.merge!('enqueued_at' => Time.now.to_f) unless job['at']
          Queues.push(job['queue'], job['class'], job)
        end
        true
      elsif Sidekiq::Testing.inline?
        payloads.each do |job|
          klass = Sidekiq::Testing.constantize(job['class'])
          job['id'] ||= SecureRandom.hex(12)
          job_hash = Sidekiq.load_json(Sidekiq.dump_json(job))
          klass.process_job(job_hash)
        end
        true
      else
        raw_push_real(payloads)
      end
    end
  end

  module Queues
    ##
    # The Queues class is only for testing the fake queue implementation.
    # There are 2 data structures involved in tandem. This is due to the
    # Rspec syntax of change(QueueWorker.jobs, :size). It keeps a reference
    # to the array. Because the array was dervied from a filter of the total
    # jobs enqueued, it appeared as though the array didn't change.
    #
    # To solve this, we'll keep 2 hashes containing the jobs. One with keys based
    # on the queue, and another with keys of the worker names, so the array for
    # QueueWorker.jobs is a straight reference to a real array.
    #
    # Queue-based hash:
    #
    # {
    #   "default"=>[
    #     {
    #       "class"=>"TestTesting::QueueWorker",
    #       "args"=>[1, 2],
    #       "retry"=>true,
    #       "queue"=>"default",
    #       "jid"=>"abc5b065c5c4b27fc1102833",
    #       "created_at"=>1447445554.419934
    #     }
    #   ]
    # }
    #
    # Worker-based hash:
    #
    # {
    #   "TestTesting::QueueWorker"=>[
    #     {
    #       "class"=>"TestTesting::QueueWorker",
    #       "args"=>[1, 2],
    #       "retry"=>true,
    #       "queue"=>"default",
    #       "jid"=>"abc5b065c5c4b27fc1102833",
    #       "created_at"=>1447445554.419934
    #     }
    #   ]
    # }
    #
    # Example:
    #
    #   require 'sidekiq/testing'
    #
    #   assert_equal 0, Sidekiq::Queues["default"].size
    #   HardWorker.perform_async(:something)
    #   assert_equal 1, Sidekiq::Queues["default"].size
    #   assert_equal :something, Sidekiq::Queues["default"].first['args'][0]
    #
    # You can also clear all workers' jobs:
    #
    #   assert_equal 0, Sidekiq::Queues["default"].size
    #   HardWorker.perform_async(:something)
    #   Sidekiq::Queues.clear_all
    #   assert_equal 0, Sidekiq::Queues["default"].size
    #
    # This can be useful to make sure jobs don't linger between tests:
    #
    #   RSpec.configure do |config|
    #     config.before(:each) do
    #       Sidekiq::Queues.clear_all
    #     end
    #   end
    #
    class << self
      def [](queue)
        jobs_by_queue[queue]
      end

      def push(queue, klass, job)
        jobs_by_queue[queue] << job
        jobs_by_worker[klass] << job
      end

      def jobs_by_queue
        @jobs_by_queue ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def jobs_by_worker
        @jobs_by_worker ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def delete_for(jid, queue, klass)
        jobs_by_queue[queue.to_s].delete_if { |job| job["jid"] == jid }
        jobs_by_worker[klass].delete_if { |job| job["jid"] == jid }
      end

      def clear_for(queue, klass)
        jobs_by_queue[queue].clear
        jobs_by_worker[klass].clear
      end

      def clear_all
        jobs_by_queue.clear
        jobs_by_worker.clear
      end
    end
  end

  module Worker
    ##
    # The Sidekiq testing infrastructure overrides perform_async
    # so that it does not actually touch the network.  Instead it
    # stores the asynchronous jobs in a per-class array so that
    # their presence/absence can be asserted by your tests.
    #
    # This is similar to ActionMailer's :test delivery_method and its
    # ActionMailer::Base.deliveries array.
    #
    # Example:
    #
    #   require 'sidekiq/testing'
    #
    #   assert_equal 0, HardWorker.jobs.size
    #   HardWorker.perform_async(:something)
    #   assert_equal 1, HardWorker.jobs.size
    #   assert_equal :something, HardWorker.jobs[0]['args'][0]
    #
    #   assert_equal 0, Sidekiq::Extensions::DelayedMailer.jobs.size
    #   MyMailer.delay.send_welcome_email('foo@example.com')
    #   assert_equal 1, Sidekiq::Extensions::DelayedMailer.jobs.size
    #
    # You can also clear and drain all workers' jobs:
    #
    #   assert_equal 0, Sidekiq::Extensions::DelayedMailer.jobs.size
    #   assert_equal 0, Sidekiq::Extensions::DelayedModel.jobs.size
    #
    #   MyMailer.delay.send_welcome_email('foo@example.com')
    #   MyModel.delay.do_something_hard
    #
    #   assert_equal 1, Sidekiq::Extensions::DelayedMailer.jobs.size
    #   assert_equal 1, Sidekiq::Extensions::DelayedModel.jobs.size
    #
    #   Sidekiq::Worker.clear_all # or .drain_all
    #
    #   assert_equal 0, Sidekiq::Extensions::DelayedMailer.jobs.size
    #   assert_equal 0, Sidekiq::Extensions::DelayedModel.jobs.size
    #
    # This can be useful to make sure jobs don't linger between tests:
    #
    #   RSpec.configure do |config|
    #     config.before(:each) do
    #       Sidekiq::Worker.clear_all
    #     end
    #   end
    #
    # or for acceptance testing, i.e. with cucumber:
    #
    #   AfterStep do
    #     Sidekiq::Worker.drain_all
    #   end
    #
    #   When I sign up as "foo@example.com"
    #   Then I should receive a welcome email to "foo@example.com"
    #
    module ClassMethods

      # Queue for this worker
      def queue
        self.sidekiq_options["queue"]
      end

      # Jobs queued for this worker
      def jobs
        Queues.jobs_by_worker[self.to_s]
      end

      # Clear all jobs for this worker
      def clear
        Queues.clear_for(queue, self.to_s)
      end

      # Drain and run all jobs for this worker
      def drain
        while jobs.any?
          next_job = jobs.first
          Queues.delete_for(next_job["jid"], next_job["queue"], self.to_s)
          process_job(next_job)
        end
      end

      # Pop out a single job and perform it
      def perform_one
        raise(EmptyQueueError, "perform_one called with empty job queue") if jobs.empty?
        next_job = jobs.first
        Queues.delete_for(next_job["jid"], queue, self.to_s)
        process_job(next_job)
      end

      def process_job(job)
        worker = new
        worker.jid = job['jid']
        worker.bid = job['bid'] if worker.respond_to?(:bid=)
        Sidekiq::Testing.server_middleware.invoke(worker, job, job['queue']) do
          execute_job(worker, job['args'])
        end
      end

      def execute_job(worker, args)
        worker.perform(*args)
      end
    end

    class << self
      def jobs # :nodoc:
        Queues.jobs_by_queue.values.flatten
      end

      # Clear all queued jobs across all workers
      def clear_all
        Queues.clear_all
      end

      # Drain all queued jobs across all workers
      def drain_all
        while jobs.any?
          worker_classes = jobs.map { |job| job["class"] }.uniq

          worker_classes.each do |worker_class|
            Sidekiq::Testing.constantize(worker_class).drain
          end
        end
      end
    end
  end
end

if defined?(::Rails) && Rails.respond_to?(:env) && !Rails.env.test?
  puts("**************************************************")
  puts("⛔️ WARNING: Sidekiq testing API enabled, but this is not the test environment.  Your jobs will not go to Redis.")
  puts("**************************************************")
end
