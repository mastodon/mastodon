require 'doorkeeper/oauth/client_credentials/validation'

module Doorkeeper
  module OAuth
    class ClientCredentialsRequest < BaseRequest
      class Issuer
        attr_accessor :token, :validation, :error

        def initialize(server, validation)
          @server = server
          @validation = validation
        end

        def create(client, scopes, creator = Creator.new)
          if validation.valid?
            @token = create_token(client, scopes, creator)
            @error = :server_error unless @token
          else
            @token = false
            @error = validation.error
          end
          @token
        end

        private

        def create_token(client, scopes, creator)
          ttl = Authorization::Token.access_token_expires_in(@server, client)

          creator.call(
            client,
            scopes,
            use_refresh_token: false,
            expires_in: ttl
          )
        end
      end
    end
  end
end
