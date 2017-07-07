# frozen_string_literal: true

module Omniauthable
  extend ActiveSupport::Concern

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  included do
    def omniauth_providers
      Devise.omniauth_configs.keys
    end

    def email_verified?
      email && email !~ TEMP_EMAIL_REGEX
    end
  end

  class_methods do
    def find_for_oauth(auth, signed_in_resource = nil)
      # EOLE-SSO Patch
      auth.uid = (auth.uid[0][:uid] || auth.uid[0][:user]) if auth.uid.is_a? Hashie::Array

      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)

      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : identity.user

      # Create the user if needed
      user = create_for_oauth(auth) if user.nil?

      # Associate the identity with the user if needed
      if identity.user.nil?
        identity.user = user
        identity.save!
      end

      user
    end

    def create_for_oauth(auth)
      # Check if the user exists with provided email if the provider gives us a
      # verified email.  If no verified email was provided or the user already
      # exists, we assign a temporary email and ask the user to verify it on
      # the next step via Auth::ConfirmationsController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified && !User.exists?(email: auth.info.email)
      username = auth.uid
      i = 0
      while Account.exists?(username: username)
        i += 1
        username = "#{auth.uid}_#{i}"
      end
      user = User.new(
        email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
        password: Devise.friendly_token[0, 20],
        account: Account.new(
          username: username,
          display_name: [auth.info.first_name, auth.info.last_name].join(' ')
        )
      )
      user.account.avatar = open(auth.info.image, allow_redirections: :safe) if auth.info.image =~ /\A#{URI.regexp(%w(http https))}\z/
      user.skip_confirmation!
      user.save!
      user
    end
  end
end
