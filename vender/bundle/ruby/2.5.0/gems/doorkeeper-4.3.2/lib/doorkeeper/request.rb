require 'doorkeeper/request/authorization_code'
require 'doorkeeper/request/client_credentials'
require 'doorkeeper/request/code'
require 'doorkeeper/request/password'
require 'doorkeeper/request/refresh_token'
require 'doorkeeper/request/token'

module Doorkeeper
  module Request
    module_function

    def authorization_strategy(response_type)
      get_strategy response_type, authorization_response_types
    rescue NameError
      raise Errors::InvalidAuthorizationStrategy
    end

    def token_strategy(grant_type)
      get_strategy grant_type, token_grant_types
    rescue NameError
      raise Errors::InvalidTokenStrategy
    end

    def get_strategy(grant_or_request_type, available)
      fail Errors::MissingRequestStrategy unless grant_or_request_type.present?
      fail NameError unless available.include?(grant_or_request_type.to_s)
      strategy_class(grant_or_request_type)
    end

    def authorization_response_types
      Doorkeeper.configuration.authorization_response_types
    end
    private_class_method :authorization_response_types

    def token_grant_types
      Doorkeeper.configuration.token_grant_types
    end
    private_class_method :token_grant_types

    def strategy_class(grant_or_request_type)
      strategy_class_name = grant_or_request_type.to_s.tr(' ', '_').camelize
      "Doorkeeper::Request::#{strategy_class_name}".constantize
    end
    private_class_method :strategy_class
  end
end
