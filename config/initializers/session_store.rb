# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails
  .application
  .config
  .session_store :cookie_store,
                 key: '_mastodon_session',
                 secure: Rails.env.production? || Rails.configuration.force_ssl,
                 same_site: :lax,
                 httponly: true
