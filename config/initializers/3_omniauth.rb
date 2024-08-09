# frozen_string_literal: true

# OmniAuth providers need to be initialized before the CSP initializer
# in `config/initializers/content_security_policy.rb`, which sets the
# `form-action` directive based on them.

Rails.application.config.middleware.use OmniAuth::Builder do
  # Vanilla omniauth strategies
end

Devise.setup do |config|
  # CAS strategy
  if Rails.configuration.x.omniauth.cas_enabled
    config.omniauth(
      :cas,
      Rails.configuration.x.omniauth.cas
    )
  end

  # SAML strategy
  if Rails.configuration.x.omniauth.saml_enabled
    config.omniauth(
      :saml,
      Rails.configuration.x.omniauth.saml
    )
  end

  # OpenID Connect Strategy
  if Rails.configuration.x.omniauth.oidc_enabled
    config.omniauth(
      :openid_connect,
      Rails.configuration.x.omniauth.oidc
    )
  end
end
