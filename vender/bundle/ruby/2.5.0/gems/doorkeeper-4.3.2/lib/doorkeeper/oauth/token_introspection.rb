module Doorkeeper
  module OAuth
    # RFC7662 OAuth 2.0 Token Introspection
    #
    # @see https://tools.ietf.org/html/rfc7662
    class TokenIntrospection
      attr_reader :server, :token
      attr_reader :error

      def initialize(server, token)
        @server = server
        @token = token

        authorize!
      end

      def authorized?
        @error.blank?
      end

      def to_json
        active? ? success_response : failure_response
      end

      private

      # If the protected resource uses OAuth 2.0 client credentials to
      # authenticate to the introspection endpoint and its credentials are
      # invalid, the authorization server responds with an HTTP 401
      # (Unauthorized) as described in Section 5.2 of OAuth 2.0 [RFC6749].
      #
      # Endpoint must first validate the authentication.
      # If the authentication is invalid, the endpoint should respond with
      # an HTTP 401 status code and an invalid_client response.
      #
      # @see https://www.oauth.com/oauth2-servers/token-introspection-endpoint/
      #
      def authorize!
        # Requested client authorization
        if server.credentials
          @error = :invalid_client unless authorized_client
        else
          # Requested bearer token authorization
          @error = :invalid_request unless authorized_token
        end
      end

      # Client Authentication
      def authorized_client
        @_authorized_client ||= server.credentials && server.client
      end

      # Bearer Token Authentication
      def authorized_token
        @_authorized_token ||=
          OAuth::Token.authenticate(server.context.request, :from_bearer_authorization)
      end

      # 2.2. Introspection Response
      def success_response
        {
          active: true,
          scope: @token.scopes_string,
          client_id: @token.try(:application).try(:uid),
          token_type: @token.token_type,
          exp: @token.expires_at.to_i,
          iat: @token.created_at.to_i
        }
      end

      # If the introspection call is properly authorized but the token is not
      # active, does not exist on this server, or the protected resource is
      # not allowed to introspect this particular token, then the
      # authorization server MUST return an introspection response with the
      # "active" field set to "false".  Note that to avoid disclosing too
      # much of the authorization server's state to a third party, the
      # authorization server SHOULD NOT include any additional information
      # about an inactive token, including why the token is inactive.
      #
      # @see https://tools.ietf.org/html/rfc7662 2.2. Introspection Response
      #
      def failure_response
        {
          active: false
        }
      end

      # Boolean indicator of whether or not the presented token
      # is currently active.  The specifics of a token's "active" state
      # will vary depending on the implementation of the authorization
      # server and the information it keeps about its tokens, but a "true"
      # value return for the "active" property will generally indicate
      # that a given token has been issued by this authorization server,
      # has not been revoked by the resource owner, and is within its
      # given time window of validity (e.g., after its issuance time and
      # before its expiration time).
      #
      # Any other error is considered an "inactive" token.
      #
      # * The token requested does not exist or is invalid
      # * The token expired
      # * The token was issued to a different client than is making this request
      #
      def active?
        if authorized_client
          valid_token? && authorized_for_client?
        else
          valid_token?
        end
      end

      # Token can be valid only if it is not expired or revoked.
      def valid_token?
        @token.present? && @token.accessible?
      end

      # If token doesn't belong to some client, then it is public.
      # Otherwise in it required for token to be connected to the same client.
      def authorized_for_client?
        if @token.application.present?
          @token.application == authorized_client.application
        else
          true
        end
      end
    end
  end
end
