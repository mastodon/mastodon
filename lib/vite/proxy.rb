# frozen_string_literal: true

require 'rack/proxy'

module Vite
  # Simple proxy that redirects asset requests to the running Vite dev server
  class Proxy < Rack::Proxy
    attr_reader :config, :dev_server

    def initialize(app, config:, dev_server:, **)
      @config = config
      @dev_server = dev_server

      super(app, backend: config.backend, ssl_verify_none: !config.https?, **)
    end

    def perform_request(env)
      if dev_server.running? && env['PATH_INFO'].start_with?(config.base_path)
        super
      else
        @app.call(env)
      end
    end
  end
end
