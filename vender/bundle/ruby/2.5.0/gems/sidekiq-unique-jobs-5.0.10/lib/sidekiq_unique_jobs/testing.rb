# frozen_string_literal: true

require 'sidekiq_unique_jobs/testing/sidekiq_overrides'
require 'sidekiq_unique_jobs/script_mock'

module SidekiqUniqueJobs
  alias redis_version_real redis_version
  def redis_version
    if mocked?
      '0.0'
    else
      redis_version_real
    end
  end

  module Scripts
    module Overrides
      def self.included(base)
        base.extend Testing
        base.class_eval do
          class << self
            alias_method :call_orig, :call
            alias_method :call, :call_ext
          end
        end
      end

      module Testing
        def call_ext(file_name, redis_pool, options = {})
          if SidekiqUniqueJobs.mocked?
            SidekiqUniqueJobs::ScriptMock.call(file_name, redis_pool, options)
          else
            call_orig(file_name, redis_pool, options)
          end
        end
      end
    end

    include Overrides
  end

  module Client
    class Middleware
      alias call_real call
      def call(worker_class, item, queue, redis_pool = nil)
        worker_class = SidekiqUniqueJobs.worker_class_constantize(worker_class)

        if Sidekiq::Testing.inline?
          call_real(worker_class, item, queue, redis_pool) do
            _server.call(worker_class.new, item, queue, redis_pool) do
              yield
            end
          end
        else
          call_real(worker_class, item, queue, redis_pool) do
            yield
          end
        end
      end

      def _server
        SidekiqUniqueJobs::Server::Middleware.new
      end
    end
  end

  class Testing
    def mocking!
      require 'sidekiq_unique_jobs/testing/mocking'
    end
  end
end
