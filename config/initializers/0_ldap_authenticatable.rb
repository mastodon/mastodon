require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def valid?
        Rails.configuration.x.use_ldap && params[:user].present?
      end

      def authenticate!
        config = Rails.configuration

        ldap = Net::LDAP.new
        ldap.host = config.x.ldap_host
        ldap.port = config.x.ldap_port

        if config.x.ldap_manager_bind
          ldap.auth config.x.ldap_manager_dn, config.x.ldap_manager_password

          if !ldap.bind
            return fail(:ldap_configuration_error)
          end

          search_filter = config.x.ldap_search_filter % { username: params[:user][:ldap_username] }

          result = ldap.search(base: config.x.ldap_search_base, filter: search_filter, result_set: true)

          if result.count != 1
            return login_fail
          end

          user_dn    = result.first.dn
          user_email = result.first[config.x.ldap_mail_attribute].first
          user_name  = result.first[config.x.ldap_username_attribute].first
        else
          user_dn = config.x.ldap_bind_template % { username: params[:user][:ldap_username] }
        end

        ldap.auth user_dn, params[:user][:password]

        if ldap.bind
          user = User.find_by(ldap_dn: user_dn)

          # We don't want to trust too much the email attribute from
          # LDAP: if the user can edit it himself, he may login as
          # anyone
          if user.nil?
            if !config.x.ldap_manager_bind
              result = ldap.search(base: user_dn, scope: Net::LDAP::SearchScope_BaseObject, filter: "(objectClass=*)", result_set: true)
              user_email = result.first[config.x.ldap_mail_attribute].first
              user_name  = result.first[config.x.ldap_username_attribute].first
            end

            if user_email.present? && User.find_by(email: user_email).nil?
              # Password is used for remember_me token
              user = User.new(email: user_email, ldap_dn: user_dn, password: SecureRandom.hex, account_attributes: { username: user_name })
              user.locale = I18n.locale
              user.build_account if user.account.nil?
              user.save
            elsif User.find_by(email: user_email).present?
              return fail(:ldap_existing_email)
            else
              return fail(:ldap_cannot_create_account_without_email)
            end
          end

          success!(user)
        else
          return login_fail
        end
      end

      def login_fail
        if Rails.configuration.x.ldap_only
          return fail(:ldap_invalid_login)
        else
          return pass
        end
      end
    end
  end
end

Rails.application.configure do
  config.x.use_ldap = ENV.fetch('USE_LDAP') { nil }.present?
  if config.x.use_ldap
    config.x.ldap_host = ENV.fetch('LDAP_HOST') { 'localhost' }
    config.x.ldap_port = ENV.fetch('LDAP_PORT') { 389 }
    config.x.ldap_only = ENV.fetch('LDAP_ONLY') { nil }.present?

    config.x.ldap_manager_bind = (ENV.fetch('LDAP_BIND_DN') { '' }).present?

    config.x.ldap_username_attribute = ENV.fetch('LDAP_USERNAME_ATTRIBUTE') { 'uid' }
    config.x.ldap_mail_attribute = ENV.fetch('LDAP_MAIL_ATTRIBUTE') { 'mail' }
    config.x.ldap_skip_email_confirmation = ENV.fetch('LDAP_SKIP_EMAIL_CONFIRMATION') { true }

    if config.x.ldap_manager_bind
      config.x.ldap_manager_dn = ENV.fetch('LDAP_BIND_DN') { '' }
      config.x.ldap_manager_password = ENV.fetch('LDAP_BIND_PW') { '' }
      config.x.ldap_search_filter = ENV.fetch('LDAP_SEARCH_FILTER') { 'uid=%{username}' }
      config.x.ldap_search_base = ENV.fetch('LDAP_SEARCH_BASE') { 'dc=example,dc=com' }
    else
      config.x.ldap_bind_template = ENV.fetch('LDAP_BIND_TEMPLATE') { 'uid=%{username},dc=example,dc=com' }
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
