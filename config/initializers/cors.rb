# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    with_options headers: :any, credentials: false do
      with_options methods: [:get] do
        resource '/.well-known/*'
        resource '/@:username'
        resource '/users/:username'
      end
      resource '/api/*',
               expose: %w(Link X-RateLimit-Reset X-RateLimit-Limit X-RateLimit-Remaining X-Request-Id),
               methods: %i(post put delete get patch options)
      resource '/oauth/token', methods: [:post]
    end
  end
end
