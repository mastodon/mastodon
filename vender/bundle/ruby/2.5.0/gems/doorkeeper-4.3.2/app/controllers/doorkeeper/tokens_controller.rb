module Doorkeeper
  class TokensController < Doorkeeper::ApplicationMetalController
    def create
      response = authorize_response
      headers.merge! response.headers
      self.response_body = response.body.to_json
      self.status = response.status
    rescue Errors::DoorkeeperError => e
      handle_token_exception e
    end

    # OAuth 2.0 Token Revocation - http://tools.ietf.org/html/rfc7009
    def revoke
      # The authorization server, if applicable, first authenticates the client
      # and checks its ownership of the provided token.
      #
      # Doorkeeper does not use the token_type_hint logic described in the
      # RFC 7009 due to the refresh token implementation that is a field in
      # the access token model.
      if authorized?
        revoke_token
      end

      # The authorization server responds with HTTP status code 200 if the token
      # has been revoked successfully or if the client submitted an invalid
      # token
      render json: {}, status: 200
    end

    def introspect
      introspection = OAuth::TokenIntrospection.new(server, token)

      if introspection.authorized?
        render json: introspection.to_json, status: 200
      else
        error = OAuth::ErrorResponse.new(name: introspection.error)
        response.headers.merge!(error.headers)
        render json: error.body, status: error.status
      end
    end

    private

    # OAuth 2.0 Section 2.1 defines two client types, "public" & "confidential".
    # Public clients (as per RFC 7009) do not require authentication whereas
    # confidential clients must be authenticated for their token revocation.
    #
    # Once a confidential client is authenticated, it must be authorized to
    # revoke the provided access or refresh token. This ensures one client
    # cannot revoke another's tokens.
    #
    # Doorkeeper determines the client type implicitly via the presence of the
    # OAuth client associated with a given access or refresh token. Since public
    # clients authenticate the resource owner via "password" or "implicit" grant
    # types, they set the application_id as null (since the claim cannot be
    # verified).
    #
    # https://tools.ietf.org/html/rfc6749#section-2.1
    # https://tools.ietf.org/html/rfc7009
    def authorized?
      if token.present?
        # Client is confidential, therefore client authentication & authorization
        # is required
        if token.application_id?
          # We authorize client by checking token's application
          server.client && server.client.application == token.application
        else
          # Client is public, authentication unnecessary
          true
        end
      end
    end

    def revoke_token
      if token.accessible?
        token.revoke
      end
    end

    def token
      @token ||= AccessToken.by_token(request.POST['token']) ||
        AccessToken.by_refresh_token(request.POST['token'])
    end

    def strategy
      @strategy ||= server.token_request params[:grant_type]
    end

    def authorize_response
      @authorize_response ||= strategy.authorize
    end
  end
end
