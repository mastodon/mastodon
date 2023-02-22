# frozen_string_literal: true

Doorkeeper::Application.create_with(name: 'Web', redirect_uri: Doorkeeper.configuration.native_redirect_uri, scopes: 'read write follow push').find_or_create_by(superapp: true)
