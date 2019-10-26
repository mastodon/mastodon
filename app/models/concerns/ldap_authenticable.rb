# frozen_string_literal: true

module LdapAuthenticable
  extend ActiveSupport::Concern

  class_methods do
    def authenticate_with_ldap(params = {})
      ldap   = Net::LDAP.new(ldap_options)
      filter = format(Devise.ldap_search_filter, uid: Devise.ldap_uid, email: params[:email])

      if (user_info = ldap.bind_as(base: Devise.ldap_base, filter: filter, password: params[:password]))
        ldap_get_user(user_info.first)
      end
    end

    def ldap_get_user(attributes = {})
      resource = joins(:account).find_by(accounts: { username: attributes[Devise.ldap_uid.to_sym].first })

      if resource.blank?
        resource = new(email: attributes[:mail].first, agreement: true, account_attributes: { username: attributes[Devise.ldap_uid.to_sym].first }, admin: false, external: true, confirmed_at: Time.now.utc)
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
