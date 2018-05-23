module Aws
  module Waiters
    module Errors

      # Raised when a waiter detects a condition where the waiter can never
      # succeed.
      class WaiterFailed < StandardError; end

      class FailureStateError < WaiterFailed

        MSG = "stopped waiting, encountered a failure state"

        def initialize(response)
          @response = response
          super(MSG)
        end

        # @return [Seahorse::Client::Response] The response that matched
        #   the failure state.
        attr_reader :response

      end

      class TooManyAttemptsError < WaiterFailed

        MSG = "stopped waiting after %d attempts without success"

        def initialize(attempts)
          @attempts = attempts
          super(MSG % [attempts])
        end

        # @return [Integer]
        attr_reader :attempts

      end

      class UnexpectedError < WaiterFailed

        MSG = "stopped waiting due to an unexpected error: %s"

        def initialize(error)
          @error = error
          super(MSG % [error.message])
        end

        # @return [Exception] The unexpected error.
        attr_reader :error

      end

      # Raised when attempting to get a waiter by name and the waiter has not
      # been defined.
      class NoSuchWaiterError < ArgumentError

        MSG = "no such waiter %s; valid waiter names are: %s"

        def initialize(waiter_name, waiter_names)
          waiter_names = waiter_names.map(&:inspect).join(', ')
          super(MSG % [waiter_name.inspect, waiter_names])
        end

      end
    end
  end
end
