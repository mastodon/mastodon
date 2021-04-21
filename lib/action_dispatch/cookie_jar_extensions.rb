# frozen_string_literal: true

module ActionDispatch
  module CookieJarExtensions
    private

    # Monkey-patch ActionDispatch to serve secure cookies to Tor Hidden Service
    # users. Otherwise, ActionDispatch would drop the cookie over HTTP.
    def write_cookie?(*)
      request.host.end_with?('.onion') || super
    end
  end
end

ActionDispatch::Cookies::CookieJar.prepend(ActionDispatch::CookieJarExtensions)

module Rack
  module SessionPersistedExtensions
    def security_matches?(request, options)
      request.host.end_with?('.onion') || super
    end
  end
end

Rack::Session::Abstract::Persisted.prepend(Rack::SessionPersistedExtensions)
