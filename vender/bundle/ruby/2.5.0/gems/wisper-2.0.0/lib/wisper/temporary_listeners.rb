# Handles temporary global subscriptions

# @api private

module Wisper
  class TemporaryListeners

    def self.subscribe(*listeners, &block)
      new.subscribe(*listeners, &block)
    end

    def self.registrations
      new.registrations
    end

    def subscribe(*listeners, &block)
      options = listeners.last.is_a?(Hash) ? listeners.pop : {}
      begin
        listeners.each { |listener| registrations << ObjectRegistration.new(listener, options) }
        yield
      ensure
        clear
      end
      self
    end

    def registrations
      Thread.current[key] ||= Set.new
    end

    private

    def clear
      registrations.clear
    end

    def key
      '__wisper_temporary_listeners'
    end
  end
end
