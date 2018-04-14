module Chewy
  class Strategy
    # The strategy works the same way as atomic, but performs
    # async index update driven by resque
    #
    #   Chewy.strategy(:resque) do
    #     User.all.map(&:save) # Does nothing here
    #     Post.all.map(&:save) # And here
    #     # It imports all the changed users and posts right here
    #   end
    #
    class Resque < Atomic
      class Worker
        @queue = :chewy

        def self.perform(type, ids, options = {})
          options[:refresh] = !Chewy.disable_refresh_async if Chewy.disable_refresh_async
          type.constantize.import!(ids, options)
        end
      end

      def leave
        @stash.all? { |type, ids| ::Resque.enqueue(Chewy::Strategy::Resque::Worker, type.name, ids) }
      end
    end
  end
end
