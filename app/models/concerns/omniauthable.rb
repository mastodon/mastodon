# frozen_string_literal: true

module Omniauthable
  extend ActiveSupport::Concern

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  included do
    def omniauth_providers
      providers = []
      providers << :cas if ENV['CAS_ENABLED']
      providers
    end

    def email_verified?
      self.email && self.email !~ TEMP_EMAIL_REGEX
    end

    def self.find_for_oauth(auth, signed_in_resource = nil)

      # EOLE-SSO Patch
      if auth.uid.is_a? Hashie::Array
        auth.uid = auth.uid[0][:uid] || auth.uid[0][:user]
      end

      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)

      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : identity.user

      # Create the user if needed
      if user.nil?

        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified
        uid = auth.uid

        if uid
          account = Account.where(username: uid).first
          user = account.try(:user)
        end
        if user.nil? and email
          user = User.where(email: email).first
        end

        # Create the user if it's a new registration
        if user.nil?
          username, i = uid, 0
          while Account.exists?(username: username) do i+=1
            username = "#{uid}_#{i}"
          end
          user = User.new(
            email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
            password: Devise.friendly_token[0,20],
            account: Account.new({
              username: username,
              display_name: [auth.info.first_name, auth.info.last_name].join(' '),
            })
          )
          user.account.avatar = open(auth.info.image, allow_redirections: :safe) if auth.info.image =~ /\A#{URI::regexp(['http', 'https'])}\z/
          user.skip_confirmation!
          user.save!
        end
      end

      # Associate the identity with the user if needed
      if identity.user != user
        identity.user = user
        identity.save!
      end
      user
    end
  end
end
