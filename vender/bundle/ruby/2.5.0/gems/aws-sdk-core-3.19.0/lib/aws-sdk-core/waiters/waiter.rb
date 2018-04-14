module Aws
  module Waiters
    # @api private
    class Waiter

      # @api private
      RAISE_HANDLER = Seahorse::Client::Plugins::RaiseResponseErrors::Handler

      # @api private
      def initialize(options = {})
        @poller = options[:poller]
        @max_attempts = options[:max_attempts]
        @delay = options[:delay]
        @before_attempt = Array(options[:before_attempt])
        @before_wait = Array(options[:before_wait])
      end

      # @api private
      attr_reader :poller

      # @return [Integer]
      attr_accessor :max_attempts

      # @return [Float]
      attr_accessor :delay

      alias interval delay
      alias interval= delay=

      # Register a callback that is invoked before every polling attempt.
      # Yields the number of attempts made so far.
      #
      #     waiter.before_attempt do |attempts|
      #       puts "#{attempts} made, about to make attempt #{attempts + 1}"
      #     end
      #
      # Throwing `:success` or `:failure` from the given block will stop
      # the waiter and return or raise. You can pass a custom message to the
      # throw:
      #
      #     # raises Aws::Waiters::Errors::WaiterFailed
      #     waiter.before_attempt do |attempts|
      #       throw :failure, 'custom-error-message'
      #     end
      #
      #     # cause the waiter to stop polling and return
      #     waiter.before_attempt do |attempts|
      #       throw :success
      #     end
      #
      # @yieldparam [Integer] attempts The number of attempts made.
      def before_attempt(&block)
        @before_attempt << Proc.new
      end

      # Register a callback that is invoked after an attempt but before
      # sleeping. Yields the number of attempts made and the previous response.
      #
      #     waiter.before_wait do |attempts, response|
      #       puts "#{attempts} made"
      #       puts response.error.inspect
      #       puts response.data.inspect
      #     end
      #
      # Throwing `:success` or `:failure` from the given block will stop
      # the waiter and return or raise. You can pass a custom message to the
      # throw:
      #
      #     # raises Aws::Waiters::Errors::WaiterFailed
      #     waiter.before_attempt do |attempts|
      #       throw :failure, 'custom-error-message'
      #     end
      #
      #     # cause the waiter to stop polling and return
      #     waiter.before_attempt do |attempts|
      #       throw :success
      #     end
      #
      #
      # @yieldparam [Integer] attempts The number of attempts already made.
      # @yieldparam [Seahorse::Client::Response] response The response from
      #   the previous polling attempts.
      def before_wait(&block)
        @before_wait << Proc.new
      end

      # @option options [Client] :client
      # @option options [Hash] :params
      def wait(options)
        catch(:success) do
          failure_msg = catch(:failure) do
            return poll(options)
          end
          raise Errors::WaiterFailed.new(failure_msg || 'waiter failed')
        end || true
      end

      private

      def poll(options)
        n = 0
        loop do
          trigger_before_attempt(n)

          state, resp = @poller.call(options)
          n += 1

          case state
          when :retry
          when :success then return resp
          when :failure then raise Errors::FailureStateError.new(resp)
          when :error   then raise Errors::UnexpectedError.new(resp.error)
          end

          raise Errors::TooManyAttemptsError.new(n) if n == @max_attempts

          trigger_before_wait(n, resp)
          sleep(@delay)
        end
      end

      def trigger_before_attempt(attempts)
        @before_attempt.each { |block| block.call(attempts) }
      end

      def trigger_before_wait(attempts, response)
        @before_wait.each { |block| block.call(attempts, response) }
      end

    end
  end
end
