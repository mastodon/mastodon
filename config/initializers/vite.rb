# frozen_string_literal: true

# Very simple proxy implementation
class Vite < Rack::Proxy
  HOST_WITH_PORT_REGEX = %r{^(.+?)(:\d+)/}

  def perform_request(env)
    if env['PATH_INFO'].start_with?('/packs-dev/')
      super
    else
      @app.call(env)
    end
  end
end

# FIXME: Disable streaming on test mode
Rails.application.config.middleware.insert_before 0, Vite, backend: 'http://localhost:3036', ssl_verify_none: true
