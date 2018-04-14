require 'doorkeeper/request/strategy'

module Doorkeeper
  module Request
    class ClientCredentials < Strategy
      delegate :client, :parameters, to: :server

      def request
        @request ||= OAuth::ClientCredentialsRequest.new(
          Doorkeeper.configuration,
          client,
          parameters
        )
      end
    end
  end
end
