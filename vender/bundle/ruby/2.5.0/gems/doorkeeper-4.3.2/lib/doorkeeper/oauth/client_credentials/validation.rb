require 'doorkeeper/validations'
require 'doorkeeper/oauth/scopes'
require 'doorkeeper/oauth/helpers/scope_checker'

module Doorkeeper
  module OAuth
    class ClientCredentialsRequest < BaseRequest
      class Validation
        include Validations
        include OAuth::Helpers

        validate :client, error: :invalid_client
        validate :scopes, error: :invalid_scope

        def initialize(server, request)
          @server, @request, @client = server, request, request.client

          validate
        end

        private

        def validate_client
          @client.present?
        end

        def validate_scopes
          return true unless @request.scopes.present?

          application_scopes = if @client.present?
                                 @client.application.scopes
                               else
                                 ''
                               end

          ScopeChecker.valid?(
            @request.scopes.to_s,
            @server.scopes,
            application_scopes
          )
        end
      end
    end
  end
end
