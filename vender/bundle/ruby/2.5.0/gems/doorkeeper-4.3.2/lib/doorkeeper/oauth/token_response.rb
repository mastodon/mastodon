module Doorkeeper
  module OAuth
    class TokenResponse
      attr_accessor :token

      def initialize(token)
        @token = token
      end

      def body
        {
          'access_token'  => token.token,
          'token_type'    => token.token_type,
          'expires_in'    => token.expires_in_seconds,
          'refresh_token' => token.refresh_token,
          'scope'         => token.scopes_string,
          'created_at'    => token.created_at.to_i
        }.reject { |_, value| value.blank? }
      end

      def status
        :ok
      end

      def headers
        { 'Cache-Control' => 'no-store',
          'Pragma' => 'no-cache',
          'Content-Type' => 'application/json; charset=utf-8' }
      end
    end
  end
end
