# frozen_string_literal: true
module Sidekiq
  module Middleware
    module Server
      class ActiveRecord

        def initialize
          # With Rails 5+ we must use the Reloader **always**.
          # The reloader handles code loading and db connection management.
          if defined?(::Rails) && ::Rails::VERSION::MAJOR >= 5
            raise ArgumentError, "Rails 5 no longer needs or uses the ActiveRecord middleware."
          end
        end

        def call(*args)
          yield
        ensure
          ::ActiveRecord::Base.clear_active_connections!
        end
      end
    end
  end
end
