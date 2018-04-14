require 'doorkeeper/request/strategy'

module Doorkeeper
  module Request
    class RefreshToken < Strategy
      delegate :credentials, :parameters, to: :server

      def refresh_token
        AccessToken.by_refresh_token(parameters[:refresh_token])
      end

      def request
        @request ||= OAuth::RefreshTokenRequest.new(
          Doorkeeper.configuration,
          refresh_token, credentials,
          parameters
        )
      end
    end
  end
end
