# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: '_mastodon_session',
  secure: false, # All cookies have their secure flag set by the force_ssl option in production
  same_site: :lax
