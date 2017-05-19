# frozen_string_literal: true

require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        return unless params[:user]

        ldap      = Net::LDAP.new
        ldap.host = host
        ldap.port = port

        ldap.auth bind_dn, bind_password if bind_dn.present?

        result = ldap.bind_as(
          base: base,
          filter: Net::LDAP::Filter.eq(email_field, email),
          size: 1,
          password: password
        )

        success!(build_user(result)) if result
        fail(:not_found_in_database) # rubocop:disable Style/SignalException
      end

      private

      def bind_dn
        ENV['LDAP_BIND_DN']
      end

      def bind_password
        ENV['LDAP_BIND_PASSWORD']
      end

      def host
        ENV.fetch('LDAP_HOST') { 'localhost' }
      end

      def port
        ENV.fetch('LDAP_PORT') { 389 }
      end

      def base
        ENV['LDAP_BASE']
      end

      def email_field
        ENV.fetch('LDAP_EMAIL_FIELD') { 'mail' }
      end

      def username_field
        ENV.fetch('LDAP_USERNAME_FIELD') { 'cn' }
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def build_user(result)
        user = User.find_by(email: email)

        return user unless user.nil?

        user = User.new(
          email: email,
          account_attributes: { username: result.first[username_field].first },
          external: true
        )

        user.skip_confirmation!
        user.save!
        user
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
