module Doorkeeper
  module OAuth
    class ClientCredentialsRequest < BaseRequest
      class Creator
        def call(client, scopes, attributes = {})
          AccessToken.find_or_create_for(
            client, nil, scopes, attributes[:expires_in],
            attributes[:use_refresh_token])
        end
      end
    end
  end
end
