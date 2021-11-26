# frozen_string_literal: true

module Omniauthable
  extend ActiveSupport::Concern

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX  = /\A#{TEMP_EMAIL_PREFIX}/.freeze

  included do
    devise :omniauthable

    def omniauth_providers
      Devise.omniauth_configs.keys
    end

    def email_present?
      email && email !~ TEMP_EMAIL_REGEX
    end
  end

  class_methods do
    def find_for_oauth(auth, signed_in_resource = nil)
      # EOLE-SSO Patch
      auth.uid = (auth.uid[0][:uid] || auth.uid[0][:user]) if auth.uid.is_a? Hashie::Array
      identity = Identity.find_for_oauth(auth)

      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user   = signed_in_resource || identity.user
      user ||= create_for_oauth(auth)

      return nil if user.nil?

      if identity.user.nil?
        identity.user = user
        identity.save!
      end

      user
    end

    def create_for_oauth(auth)
      # Check if the user exists with provided email. If no email was provided,
      # we assign a temporary email and ask the user to verify it on
      # the next step via Auth::SetupController.show

      strategy          = Devise.omniauth_configs[auth.provider.to_sym].strategy
      assume_verified   = strategy&.security&.assume_email_is_verified
      email_is_verified = auth.info.verified || auth.info.verified_email || auth.info.email_verified || assume_verified
      email             = auth.info.verified_email || auth.info.email
      # email             = nil unless email_is_verified or trusted_auth_provider(auth)

      user = User.find_by(email: email) if email_is_verified or trusted_auth_provider(auth)

      return user unless user.nil?

      return nil if is_registration_limited

      user = User.new(user_params_from_auth(email, auth))

      user.account.avatar_remote_url = auth.info.image if /\A#{URI::DEFAULT_PARSER.make_regexp(%w(http https))}\z/.match?(auth.info.image)
      user.skip_confirmation! if email_is_verified or trusted_auth_provider(auth)
      user.save!
      user
    end

    private

    def user_params_from_auth(email, auth)
      {
        email: email || "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
        agreement: true,
        external: true,
        account_attributes: {
          username: ensure_unique_username(auth),
          display_name: trusted_auth_provider_display_name(auth) || 
                        auth.info.full_name || auth.info.name || [auth.info.first_name, auth.info.last_name].join(' '),
        },
      }
    end

    def ensure_unique_username(auth)
      username = auth.uid
      auth_provideded_username = nil
      i        = 0

      if auth.provider == 'github'
        auth_provideded_username = auth.info.nickname
      elsif auth.provider == 'gitlab'
        auth_provideded_username = auth.info.username
      end

      username = auth_provideded_username unless auth_provideded_username.empty?

      username = ensure_valid_username(username)

      while Account.exists?(username: username, domain: nil)
        i       += 1
        username = "#{auth_provideded_username || auth.uid}_#{i}"
      end

      username
    end

    def ensure_valid_username(starting_username)
      starting_username = starting_username.split('@')[0]
      temp_username = starting_username.gsub(/[^a-z0-9_]+/i, '')
      validated_username = temp_username.truncate(30, omission: '')
      validated_username
    end
    
    def trusted_auth_provider(auth)
      auth.provider == 'github' || auth.provider == 'gitlab'
    end

    def trusted_auth_provider_display_name(auth)
      if auth.provider == 'github'
        return auth.info.name
      elsif auth.provider == 'gitlab'
        return auth.info.name
      end

      return nil
    end

    def is_registration_limited()
      if ENV['AUTO_REGISTRATION_WITH_AUTH_PROVIDERS'] == 'true'
        return false
      elsif Setting.registrations_mode != 'open'
        return true
      else
        return false
      end
    end
  end
end
