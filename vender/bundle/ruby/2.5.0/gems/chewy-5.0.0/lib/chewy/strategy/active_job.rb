module Chewy
  class Strategy
    # The strategy works the same way as atomic, but performs
    # async index update driven by active_job
    #
    #   Chewy.strategy(:active_job) do
    #     User.all.map(&:save) # Does nothing here
    #     Post.all.map(&:save) # And here
    #     # It imports all the changed users and posts right here
    #   end
    #
    class ActiveJob < Atomic
      class Worker < ::ActiveJob::Base
        queue_as :chewy

        def perform(type, ids, options = {})
          options[:refresh] = !Chewy.disable_refresh_async if Chewy.disable_refresh_async
          type.constantize.import!(ids, options)
        end
      end

      def leave
        @stash.each do |type, ids|
          Chewy::Strategy::ActiveJob::Worker.perform_later(type.name, ids) unless ids.empty?
        end
      end
    end
  end
end
