# @api private

module Wisper
  class BlockRegistration < Registration
    def broadcast(event, publisher, *args)
      if should_broadcast?(event)
        listener.call(*args)
      end
    end
  end
end
