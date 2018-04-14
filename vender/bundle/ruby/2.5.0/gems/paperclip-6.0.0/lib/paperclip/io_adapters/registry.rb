module Paperclip
  class AdapterRegistry
    class NoHandlerError < Paperclip::Error; end

    attr_reader :registered_handlers

    def initialize
      @registered_handlers = []
    end

    def register(handler_class, &block)
      @registered_handlers << [block, handler_class]
    end

    def unregister(handler_class)
      @registered_handlers.reject! { |_, klass| klass == handler_class }
    end

    def handler_for(target)
      @registered_handlers.each do |tester, handler|
        return handler if tester.call(target)
      end
      raise NoHandlerError.new("No handler found for #{target.inspect}")
    end

    def registered?(target)
      @registered_handlers.any? do |tester, handler|
        handler === target
      end
    end

    def for(target, options = {})
      handler_for(target).new(target, options)
    end
  end
end
