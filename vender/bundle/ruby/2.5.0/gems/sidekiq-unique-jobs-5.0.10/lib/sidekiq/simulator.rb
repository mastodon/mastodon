# frozen_string_literal: true

require 'sidekiq/launcher'
require 'timeout'

module Sidekiq
  class Simulator
    extend Forwardable
    def_delegator SidekiqUniqueJobs, :logger

    attr_reader :queues, :launcher

    def self.process_queue(queue)
      new(queue).process_queue { yield }
    end

    def initialize(queue)
      @queues = [queue].flatten.uniq
      @launcher = Sidekiq::Launcher.new(sidekiq_options(queues))
    end

    def process_queue
      run_launcher { yield }
    ensure
      terminate_launcher
    end

    private

    def run_launcher
      using_timeout(15) do
        launcher.run
        sleep 0.001 until alive?
      end
    rescue Timeout::Error => e
      logger.warn { "Timeout while running #{__method__}" }
      logger.warn { e }
    ensure
      yield
    end

    def terminate_launcher
      launcher.stop
    end

    def alive?
      launcher.manager.workers.any?
    end

    def stopped?
      !alive?
    end

    def using_timeout(value)
      Timeout.timeout(value) do
        yield
      end
    end

    def sidekiq_options(queues = [])
      { queues: queues,
        concurrency: 3,
        timeout: 3,
        verbose: false,
        logfile: './tmp/sidekiq.log' }
    end
  end
end
