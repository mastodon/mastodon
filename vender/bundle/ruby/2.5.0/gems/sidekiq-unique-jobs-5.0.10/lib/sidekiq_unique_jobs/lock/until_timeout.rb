# frozen_string_literal: true

module SidekiqUniqueJobs
  module Lock
    class UntilTimeout < UntilExecuted
      def unlock(scope)
        return true if scope.to_sym == :server

        raise ArgumentError, "#{scope} middleware can't #{__method__} #{unique_key}"
      end

      def execute(_callback)
        yield if block_given?
      end
    end
  end
end
