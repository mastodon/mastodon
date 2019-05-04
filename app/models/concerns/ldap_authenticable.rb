# frozen_string_literal: true

module LdapAuthenticable
  extend ActiveSupport::Concern

  def ldap_setup(_attributes)
    self.confirmed_at = Time.now.utc
    self.admin        = false
    self.external     = true

    save!
  end

  class_methods do
    def ldap_get_user(attributes = {})
      resource = joins(:account).find_by(accounts: { username: attributes[Devise.ldap_uid.to_sym].first })

      if resource.blank?
        resource = new(email: attributes[:mail].first, agreement: true, account_attributes: { username: attributes[Devise.ldap_uid.to_sym].first })
        resource.ldap_setup(attributes)
      end

      resource
    end
  end
end
