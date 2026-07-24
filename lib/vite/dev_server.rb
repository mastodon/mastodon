# frozen_string_literal: true

module Vite
  # Check the status of Vite's dev server
  class DevServer
    WAIT_TIME = 5 # seconds
    attr_reader :config

    def initialize(config)
      @config = config
    end

    # Original idea from vite_ruby gem
    def running?
      return @running if defined?(@running) && Time.now.to_i - @running_checked_at < WAIT_TIME

      Socket.tcp(config.host, config.port).close
      @running = true
    rescue
      @running = false
    ensure
      @running_checked_at = Time.now.to_i
    end
  end
end
