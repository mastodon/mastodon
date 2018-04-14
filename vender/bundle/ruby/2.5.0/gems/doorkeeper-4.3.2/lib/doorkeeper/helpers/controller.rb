# Define methods that can be called in any controller that inherits from
# Doorkeeper::ApplicationMetalController or Doorkeeper::ApplicationController
module Doorkeeper
  module Helpers
    module Controller
      private

      # :doc:
      def authenticate_resource_owner!
        current_resource_owner
      end

      # :doc:
      def current_resource_owner
        instance_eval(&Doorkeeper.configuration.authenticate_resource_owner)
      end

      def resource_owner_from_credentials
        instance_eval(&Doorkeeper.configuration.resource_owner_from_credentials)
      end

      # :doc:
      def authenticate_admin!
        instance_eval(&Doorkeeper.configuration.authenticate_admin)
      end

      def server
        @server ||= Server.new(self)
      end

      # :doc:
      def doorkeeper_token
        @token ||= OAuth::Token.authenticate request, *config_methods
      end

      def config_methods
        @methods ||= Doorkeeper.configuration.access_token_methods
      end

      def get_error_response_from_exception(exception)
        OAuth::ErrorResponse.new name: exception.type, state: params[:state]
      end

      def handle_token_exception(exception)
        error = get_error_response_from_exception exception
        headers.merge! error.headers
        self.response_body = error.body.to_json
        self.status        = error.status
      end

      def skip_authorization?
        !!instance_exec([@server.current_resource_owner, @pre_auth.client], &Doorkeeper.configuration.skip_authorization)
      end
    end
  end
end
