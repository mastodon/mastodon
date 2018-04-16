module Doorkeeper
  module OAuth
    class ForbiddenTokenResponse < ErrorResponse
      def self.from_scopes(scopes, attributes = {})
        new(attributes.merge(scopes: scopes))
      end

      def initialize(attributes = {})
        super(attributes.merge(name: :invalid_scope, state: :forbidden))
        @scopes = attributes[:scopes]
      end

      def status
        :forbidden
      end

      def headers
        headers = super
        headers.delete 'WWW-Authenticate'
        headers
      end

      def description
        scope = { scope: %i[doorkeeper scopes] }
        @description ||= @scopes.map { |r| I18n.translate r, scope }.join('\n')
      end
    end
  end
end
