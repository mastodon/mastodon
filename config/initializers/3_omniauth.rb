# frozen_string_literal: true

# OmniAuth providers need to be initialized before the CSP initializer
# in `config/initializers/content_security_policy.rb`, which sets the
# `form-action` directive based on them.

Rails.application.config.middleware.use OmniAuth::Builder do
  # Vanilla omniauth strategies
end

Devise.setup do |config|
  # CAS strategy
  if Rails.configuration.omniauth.cas_enabled
    config.omniauth(
      :cas,
      Rails.configuration.omniauth.cas
    )
  end

  # SAML strategy
  if Rails.configuration.omniauth.saml_enabled
    config.omniauth(
      :saml,
      Rails.configuration.omniauth.saml
    )
  end

  # OpenID Connect Strategy
  if Rails.configuration.omniauth.oidc_enabled
    oidc_options = Rails.configuration.omniauth.oidc

    config.omniauth(
      :openid_connect,
      oidc_options.merge(
        scope: oidc_options[:scope].split(',').map(&:to_sym) # Convert scope to symbol array
      )
    )
  end
end
