module Doorkeeper
  module OAuth
    module Authorization
      class Code
        attr_accessor :pre_auth, :resource_owner, :token

        def initialize(pre_auth, resource_owner)
          @pre_auth       = pre_auth
          @resource_owner = resource_owner
        end

        def issue_token
          @token ||= AccessGrant.create!(
            application_id: pre_auth.client.id,
            resource_owner_id: resource_owner.id,
            expires_in: configuration.authorization_code_expires_in,
            redirect_uri: pre_auth.redirect_uri,
            scopes: pre_auth.scopes.to_s
          )
        end

        def native_redirect
          { action: :show, code: token.token }
        end

        def configuration
          Doorkeeper.configuration
        end
      end
    end
  end
end
