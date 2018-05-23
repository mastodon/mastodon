# frozen_string_literal: true

require 'devise/strategies/base'

module Devise
  module Strategies
    # This strategy should be used as basis for authentication strategies. It retrieves
    # parameters both from params or from http authorization headers. See database_authenticatable
    # for an example.
    class Authenticatable < Base
      attr_accessor :authentication_hash, :authentication_type, :password

      def store?
        super && !mapping.to.skip_session_storage.include?(authentication_type)
      end

      def valid?
        valid_for_params_auth? || valid_for_http_auth?
      end

      # Override and set to false for things like OmniAuth that technically
      # run through Authentication (user_set) very often, which would normally
      # reset CSRF data in the session
      def clean_up_csrf?
        true
      end

    private

      # Receives a resource and check if it is valid by calling valid_for_authentication?
      # An optional block that will be triggered while validating can be optionally
      # given as parameter. Check Devise::Models::Authenticatable.valid_for_authentication?
      # for more information.
      #
      # In case the resource can't be validated, it will fail with the given
      # unauthenticated_message.
      def validate(resource, &block)
        result = resource && resource.valid_for_authentication?(&block)

        if result
          true
        else
          if resource
            fail!(resource.unauthenticated_message)
          end
          false
        end
      end

      # Get values from params and set in the resource.
      def remember_me(resource)
        resource.remember_me = remember_me? if resource.respond_to?(:remember_me=)
      end

      # Should this resource be marked to be remembered?
      def remember_me?
        valid_params? && Devise::TRUE_VALUES.include?(params_auth_hash[:remember_me])
      end

      # Check if this is a valid strategy for http authentication by:
      #
      #   * Validating if the model allows http authentication;
      #   * If any of the authorization headers were sent;
      #   * If all authentication keys are present;
      #
      def valid_for_http_auth?
        http_authenticatable? && request.authorization && with_authentication_hash(:http_auth, http_auth_hash)
      end

      # Check if this is a valid strategy for params authentication by:
      #
      #   * Validating if the model allows params authentication;
      #   * If the request hits the sessions controller through POST;
      #   * If the params[scope] returns a hash with credentials;
      #   * If all authentication keys are present;
      #
      def valid_for_params_auth?
        params_authenticatable? && valid_params_request? &&
          valid_params? && with_authentication_hash(:params_auth, params_auth_hash)
      end

      # Check if the model accepts this strategy as http authenticatable.
      def http_authenticatable?
        mapping.to.http_authenticatable?(authenticatable_name)
      end

      # Check if the model accepts this strategy as params authenticatable.
      def params_authenticatable?
        mapping.to.params_authenticatable?(authenticatable_name)
      end

      # Extract the appropriate subhash for authentication from params.
      def params_auth_hash
        params[scope]
      end

      # Extract a hash with attributes:values from the http params.
      def http_auth_hash
        keys = [http_authentication_key, :password]
        Hash[*keys.zip(decode_credentials).flatten]
      end

      # By default, a request is valid if the controller set the proper env variable.
      def valid_params_request?
        !!env["devise.allow_params_authentication"]
      end

      # If the request is valid, finally check if params_auth_hash returns a hash.
      def valid_params?
        params_auth_hash.is_a?(Hash)
      end

      # Note: unlike `Model.valid_password?`, this method does not actually
      # ensure that the password in the params matches the password stored in
      # the database. It only checks if the password is *present*. Do not rely
      # on this method for validating that a given password is correct.
      def valid_password?
        password.present?
      end

      # Helper to decode credentials from HTTP.
      def decode_credentials
        return [] unless request.authorization && request.authorization =~ /^Basic (.*)/mi
        Base64.decode64($1).split(/:/, 2)
      end

      # Sets the authentication hash and the password from params_auth_hash or http_auth_hash.
      def with_authentication_hash(auth_type, auth_values)
        self.authentication_hash, self.authentication_type = {}, auth_type
        self.password = auth_values[:password]

        parse_authentication_key_values(auth_values, authentication_keys) &&
        parse_authentication_key_values(request_values, request_keys)
      end

      def authentication_keys
        @authentication_keys ||= mapping.to.authentication_keys
      end

      def http_authentication_key
        @http_authentication_key ||= mapping.to.http_authentication_key || case authentication_keys
          when Array then authentication_keys.first
          when Hash then authentication_keys.keys.first
        end
      end

      def request_keys
        @request_keys ||= mapping.to.request_keys
      end

      def request_values
        keys = request_keys.respond_to?(:keys) ? request_keys.keys : request_keys
        values = keys.map { |k| self.request.send(k) }
        Hash[keys.zip(values)]
      end

      def parse_authentication_key_values(hash, keys)
        keys.each do |key, enforce|
          value = hash[key].presence
          if value
            self.authentication_hash[key] = value
          else
            return false unless enforce == false
          end
        end
        true
      end

      # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
      # becomes simply :database.
      def authenticatable_name
        @authenticatable_name ||=
          ActiveSupport::Inflector.underscore(self.class.name.split("::").last).
            sub("_authenticatable", "").to_sym
      end
    end
  end
end
