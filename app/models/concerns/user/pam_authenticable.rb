# frozen_string_literal: true

module User::PamAuthenticable
  extend ActiveSupport::Concern

  included do
    devise :pam_authenticatable if ENV['PAM_ENABLED'] == 'true'

    def pam_conflict(_attributes)
      # Block pam login tries on traditional account
    end

    def pam_conflict?
      if Devise.pam_authentication
        encrypted_password.present? && pam_managed_user?
      else
        false
      end
    end

    def pam_get_name
      if account.present?
        account.username
      else
        super
      end
    end

    def pam_setup(_attributes)
      account = Account.new(username: pam_get_name)
      account.save!(validate: false)

      self.email        = "#{account.username}@#{find_pam_suffix}" if email.nil? && find_pam_suffix
      self.confirmed_at = Time.now.utc
      self.account      = account
      self.external     = true

      account.destroy! unless save
    end

    def self.pam_get_user(attributes = {})
      return nil unless attributes[:email]

      resource = if Devise.check_at_sign && !attributes[:email].index('@')
                   joins(:account).find_by(accounts: { username: attributes[:email] })
                 else
                   find_by(email: attributes[:email])
                 end

      if resource.nil?
        resource = new(email: attributes[:email], agreement: true)

        if Devise.check_at_sign && !resource[:email].index('@')
          resource[:email] = Rpam2.getenv(resource.find_pam_service, attributes[:email], attributes[:password], 'email', false)
          resource[:email] = "#{attributes[:email]}@#{resource.find_pam_suffix}" unless resource[:email]
        end
      end

      resource
    end

    def self.authenticate_with_pam(attributes = {})
      super if Devise.pam_authentication
    end
  end
end
