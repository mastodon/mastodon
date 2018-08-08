# frozen_string_literal: true

require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          ldap = Net::LDAP.new(
            host: Devise.ldap_host,
            port: Devise.ldap_port,
            base: Devise.ldap_base,
            encryption: {
              method: Devise.ldap_method,
              tls_options: tls_options,
            },
            auth: {
              method: :simple,
              username: Devise.ldap_bind_dn,
              password: Devise.ldap_password,
            },
            connect_timeout: 10
          )

          filter = format(Devise.ldap_search_filter, uid: Devise.ldap_uid, email: email)
          if (user_info = ldap.bind_as(base: Devise.ldap_base, filter: filter, password: password))
            user = User.ldap_get_user(user_info.first)
            success!(user)
          else
            return fail(:invalid_login)
          end
        end
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def tls_options
        OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.tap do |options|
          options[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if Devise.ldap_tls_no_verify
        end
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
