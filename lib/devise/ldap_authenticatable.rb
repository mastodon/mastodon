# frozen_string_literal: true

if ENV['LDAP_ENABLED'] == 'true'
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
                tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
              },
              auth: {
                method: :simple,
                username: Devise.ldap_bind_dn,
                password: Devise.ldap_password,
              },
              connect_timeout: 10
            )

            if (user_info = ldap.bind_as(base: Devise.ldap_base, filter: "(#{Devise.ldap_uid}=#{email})", password: password))
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
      end
    end
  end

  Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
end
