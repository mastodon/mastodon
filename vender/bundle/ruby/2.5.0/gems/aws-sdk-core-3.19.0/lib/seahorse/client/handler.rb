module Seahorse
  module Client
    class Handler

      # @param [Handler] handler (nil) The next handler in the stack that
      #   should be called from within the {#call} method.  This value
      #   must only be nil for send handlers.
      def initialize(handler = nil)
        @handler = handler
      end

      # @return [Handler, nil]
      attr_accessor :handler

      # @param [RequestContext] context
      # @return [Response]
      def call(context)
        @handler.call(context)
      end

      def inspect
        "#<#{self.class.name||'UnnamedHandler'} @handler=#{@handler.inspect}>"
      end
    end
  end
end
