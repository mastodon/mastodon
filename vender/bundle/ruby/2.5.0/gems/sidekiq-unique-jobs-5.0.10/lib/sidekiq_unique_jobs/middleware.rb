# frozen_string_literal: true

require 'sidekiq'

module SidekiqUniqueJobs
  module Middleware
    def self.extended(base)
      base.class_eval do
        configure_middleware
      end
    end

    def configure_middleware
      configure_server_middleware
      configure_client_middleware
    end

    def configure_server_middleware
      Sidekiq.configure_server do |config|
        config.client_middleware do |chain|
          require 'sidekiq_unique_jobs/client/middleware'
          chain.add SidekiqUniqueJobs::Client::Middleware
        end

        config.server_middleware do |chain|
          require 'sidekiq_unique_jobs/server/middleware'
          chain.add SidekiqUniqueJobs::Server::Middleware
        end
      end
    end

    def configure_client_middleware
      Sidekiq.configure_client do |config|
        config.client_middleware do |chain|
          require 'sidekiq_unique_jobs/client/middleware'
          chain.add SidekiqUniqueJobs::Client::Middleware
        end
      end
    end
  end
end
SidekiqUniqueJobs.send(:extend, SidekiqUniqueJobs::Middleware)
