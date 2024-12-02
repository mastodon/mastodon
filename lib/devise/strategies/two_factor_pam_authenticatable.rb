# frozen_string_literal: true

require 'devise/strategies/base'

module Devise
  module Strategies
    class TwoFactorPamAuthenticatable < Base
      def valid?
        valid_params? && mapping.to.respond_to?(:authenticate_with_pam)
      end

      def authenticate!
        resource = mapping.to.authenticate_with_pam(params[scope])

        if resource && !resource.otp_required_for_login?
          success!(resource)
        else
          fail(:invalid) # rubocop:disable Style/SignalException -- method is from Warden::Strategies::Base
        end
      end

      protected

      def valid_params?
        params[scope] && params[scope][:password].present?
      end
    end
  end
end

Warden::Strategies.add(:two_factor_pam_authenticatable, Devise::Strategies::TwoFactorPamAuthenticatable)
