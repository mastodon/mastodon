# frozen_string_literal: true

require 'sidekiq/testing'

module Sidekiq
  module Worker
    module ClassMethods
      # Clear all jobs for this worker
      def clear
        jobs.each do |job|
          unlock(job) if Sidekiq::Testing.fake?
        end

        Sidekiq::Queues[queue].clear
        jobs.clear
      end

      unless respond_to?(:execute_job)
        def execute_job(worker, args)
          worker.perform(*args)
        end
      end

      def unlock(job)
        SidekiqUniqueJobs::Unlockable.unlock(job)
      end
    end

    module Overrides
      def self.included(base)
        base.extend Testing
        base.class_eval do
          class << self
            alias_method :clear_all_orig, :clear_all
            alias_method :clear_all, :clear_all_ext
          end
        end
      end

      module Testing
        def clear_all_ext
          SidekiqUniqueJobs::Util.del('*', 1000, false) unless SidekiqUniqueJobs.mocked?
          clear_all_orig
        end
      end
    end

    include Overrides
  end
end
