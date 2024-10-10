# frozen_string_literal: true

require 'net/ldap'
require 'devise/strategies/base'

module Devise
  module Strategies
    class TwoFactorLdapAuthenticatable < Base
      def valid?
        valid_params? && mapping.to.respond_to?(:authenticate_with_ldap)
      end

      def authenticate!
        resource = mapping.to.authenticate_with_ldap(params[scope])

        fail(:invalid) unless resource && !resource.otp_required_for_login? # rubocop:disable Style/SignalException -- method is from Warden::Strategies::Base

        success!(resource)
      end

      protected

      def valid_params?
        params[scope] && params[scope][:password].present?
      end
    end
  end
end

Warden::Strategies.add(:two_factor_ldap_authenticatable, Devise::Strategies::TwoFactorLdapAuthenticatable)
