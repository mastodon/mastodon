# frozen_string_literal: true
module Excon
  module Middleware
    class Base
      def initialize(stack)
        @stack = stack
      end

      def error_call(datum)
        # do stuff
        @stack.error_call(datum)
      end

      def request_call(datum)
        # do stuff
        @stack.request_call(datum)
      end

      def response_call(datum)
        @stack.response_call(datum)
        # do stuff
      end
    end
  end
end
