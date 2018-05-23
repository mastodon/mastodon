# frozen_string_literal: true
require 'socket'
require 'securerandom'
require 'sidekiq/exception_handler'

module Sidekiq
  ##
  # This module is part of Sidekiq core and not intended for extensions.
  #
  module Util
    include ExceptionHandler

    EXPIRY = 60 * 60 * 24

    def watchdog(last_words)
      yield
    rescue Exception => ex
      handle_exception(ex, { context: last_words })
      raise ex
    end

    def safe_thread(name, &block)
      Thread.new do
        Thread.current['sidekiq_label'] = name
        watchdog(name, &block)
      end
    end

    def logger
      Sidekiq.logger
    end

    def redis(&block)
      Sidekiq.redis(&block)
    end

    def hostname
      ENV['DYNO'] || Socket.gethostname
    end

    def process_nonce
      @@process_nonce ||= SecureRandom.hex(6)
    end

    def identity
      @@identity ||= "#{hostname}:#{$$}:#{process_nonce}"
    end

    def fire_event(event, options={})
      reverse = options[:reverse]
      reraise = options[:reraise]

      arr = Sidekiq.options[:lifecycle_events][event]
      arr.reverse! if reverse
      arr.each do |block|
        begin
          block.call
        rescue => ex
          handle_exception(ex, { context: "Exception during Sidekiq lifecycle event.", event: event })
          raise ex if reraise
        end
      end
      arr.clear
    end
  end
end
