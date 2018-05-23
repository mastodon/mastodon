module Doorkeeper
  module Models
    module Accessible
      # Indicates whether the object is accessible (not expired and not revoked).
      #
      # @return [Boolean] true if object accessible or false in other case
      #
      def accessible?
        !expired? && !revoked?
      end
    end
  end
end
