# frozen_string_literal: true

module Chewy
  class Strategy
    class CustomSidekiq < Base
      class Worker
        include ::Sidekiq::Worker

        sidekiq_options queue: 'pull'

        def perform(type, ids, options = {})
          options[:refresh] = !Chewy.disable_refresh_async if Chewy.disable_refresh_async
          type.constantize.import!(ids, options)
        end
      end

      def update(type, objects, _options = {})
        return unless Chewy.enabled?

        ids = type.root.id ? Array.wrap(objects) : type.adapter.identify(objects)

        return if ids.empty?

        Worker.perform_async(type.name, ids)
      end

      def leave; end
    end
  end
end
