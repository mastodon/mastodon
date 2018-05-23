require 'doorkeeper/request/strategy'

module Doorkeeper
  module Request
    class Password < Strategy
      delegate :credentials, :resource_owner, :parameters, to: :server

      def request
        @request ||= OAuth::PasswordAccessTokenRequest.new(
          Doorkeeper.configuration,
          client,
          resource_owner,
          parameters
        )
      end

      private

      def client
        if credentials
          server.client
        elsif parameters[:client_id]
          server.client_via_uid
        end
      end
    end
  end
end
