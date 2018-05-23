# frozen_string_literal: true

module SidekiqUniqueJobs
  module Lock
    class UntilExecuting < UntilExecuted
      def execute(callback, &_block)
        callback.call if unlock(:server)
        yield
      end
    end
  end
end
