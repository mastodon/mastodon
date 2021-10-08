# frozen_string_literal: true

module Chewy
  class Strategy
    class CustomSidekiq < Sidekiq
      def update(_type, _objects, _options = {})
        super if Chewy.enabled?
      end
    end
  end
end
