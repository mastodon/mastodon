module Doorkeeper
  module AccessGrantMixin
    extend ActiveSupport::Concern

    include OAuth::Helpers
    include Models::Expirable
    include Models::Revocable
    include Models::Accessible
    include Models::Orderable
    include Models::Scopes

    module ClassMethods
      # Searches for Doorkeeper::AccessGrant record with the
      # specific token value.
      #
      # @param token [#to_s] token value (any object that responds to `#to_s`)
      #
      # @return [Doorkeeper::AccessGrant, nil] AccessGrant object or nil
      #   if there is no record with such token
      #
      def by_token(token)
        find_by(token: token.to_s)
      end
    end
  end
end
