module Chewy
  class Strategy
    # The strategy works the same way as atomic, but performs
    # async index update driven by shoryuken
    #
    #   Chewy.strategy(:shoryuken) do
    #     User.all.map(&:save) # Does nothing here
    #     Post.all.map(&:save) # And here
    #     # It imports all the changed users and posts right here
    #   end
    #
    class Shoryuken < Atomic
      class Worker
        include ::Shoryuken::Worker

        shoryuken_options auto_delete: true,
                          body_parser: :json

        def perform(_sqs_msg, body)
          options = body['options'] || {}
          options[:refresh] = !Chewy.disable_refresh_async if Chewy.disable_refresh_async
          body['type'].constantize.import!(body['ids'], options.deep_symbolize_keys!)
        end
      end

      def leave
        @stash.each do |type, ids|
          next if ids.empty?
          Shoryuken::Worker.perform_async({type: type.name, ids: ids}, queue: shoryuken_queue)
        end
      end

    private

      def shoryuken_queue
        Chewy.settings.fetch(:shoryuken, {})[:queue] || 'chewy'
      end
    end
  end
end
