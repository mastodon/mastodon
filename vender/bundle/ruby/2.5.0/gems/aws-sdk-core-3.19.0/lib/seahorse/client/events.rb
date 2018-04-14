module Seahorse
  module Client
    module EventEmitter

      def initialize(*args)
        @listeners = {}
        super
      end

      def emit(event_name, *args, &block)
        @listeners[event_name] ||= []
        @listeners[event_name] << Proc.new
      end

      def signal(event, *args)
        @listeners
      end

    end
  end
end
