module Doorkeeper
  module OAuth
    class BaseRequest
      include Validations

      def authorize
        validate

        if valid?
          before_successful_response
          @response = TokenResponse.new(access_token)
          after_successful_response
          @response
        else
          @response = ErrorResponse.from_request(self)
        end
      end

      def scopes
        @scopes ||= if @original_scopes.present?
                      OAuth::Scopes.from_string(@original_scopes)
                    else
                      default_scopes
                    end
      end

      def default_scopes
        server.default_scopes
      end

      def valid?
        error.nil?
      end

      def find_or_create_access_token(client, resource_owner_id, scopes, server)
        @access_token = AccessToken.find_or_create_for(
          client,
          resource_owner_id,
          scopes,
          Authorization::Token.access_token_expires_in(server, client),
          server.refresh_token_enabled?
        )
      end

      def before_successful_response
        Doorkeeper.configuration.before_successful_strategy_response.call(self)
      end

      def after_successful_response
        Doorkeeper.configuration.after_successful_strategy_response.
          call(self, @response)
      end
    end
  end
end
