# frozen_string_literal: true

module SidekiqUniqueJobs
  module Lock
    class UntilAndWhileExecuting < UntilExecuting
      def execute(callback)
        lock = WhileExecuting.new(item, redis_pool)
        lock.synchronize do
          callback.call if unlock(:server)
          yield
        end
      end
    end
  end
end
