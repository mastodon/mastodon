# frozen_string_literal: true

module LdapAuthenticable
  extend ActiveSupport::Concern

  class_methods do
    def authenticate_with_ldap(params = {})
      ldap   = Net::LDAP.new(ldap_options)
      filter = format(Devise.ldap_search_filter, uid: Devise.ldap_uid, mail: Devise.ldap_mail, email: params[:email])

      if (user_info = ldap.bind_as(base: Devise.ldap_base, filter: filter, password: params[:password]))
        ldap_get_user(user_info.first)
      end
    end

    def ldap_get_user(attributes = {})
      safe_username = attributes[Devise.ldap_uid.to_sym].first

      if Devise.ldap_uid_conversion_enabled
        keys = Regexp.union(Devise.ldap_uid_conversion_search.chars)
        replacement = Devise.ldap_uid_conversion_replace
        safe_username = safe_username.gsub(keys, replacement)
      end

      resource = joins(:account).find_by(accounts: { username: safe_username })

      if resource.blank?
        resource = new(email: attributes[Devise.ldap_mail.to_sym].first, agreement: true, account_attributes: { username: safe_username }, admin: false, external: true, confirmed_at: Time.now.utc)
        resource.save!
      end

      resource
    end

    def ldap_options
      opts = {
        host: Devise.ldap_host,
        port: Devise.ldap_port,
        base: Devise.ldap_base,

        auth: {
          method: :simple,
          username: Devise.ldap_bind_dn,
          password: Devise.ldap_password,
        },

        connect_timeout: 10,
      }

      if [:simple_tls, :start_tls].include?(Devise.ldap_method)
        opts[:encryption] = {
          method: Devise.ldap_method,
          tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.tap { |options| options[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if Devise.ldap_tls_no_verify },
        }
      end

      opts
    end
  end
end
