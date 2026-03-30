# frozen_string_literal: true

require 'action_dispatch/middleware/static'

module Mastodon
  module Middleware
    class PublicFileServer
      SERVICE_WORKER_TTL = 7.days.to_i
      CACHE_TTL          = 28.days.to_i

      def initialize(app)
        @app = app
        @file_handler = ActionDispatch::FileHandler.new(Rails.application.paths['public'].first)
      end

      def call(env)
        file = @file_handler.attempt(env)

        # If the request is not a static file, move on!
        return @app.call(env) if file.nil?

        status, headers, response = file

        # Set cache headers on static files. Some paths require different cache headers
        request = Rack::Request.new env
        headers['cache-control'] = begin
          if request.path.start_with?('/sw.js')
            "public, max-age=#{SERVICE_WORKER_TTL}, must-revalidate"
          elsif request.path.start_with?(paperclip_root_url)
            "public, max-age=#{CACHE_TTL}, immutable"
          else
            "public, max-age=#{CACHE_TTL}, must-revalidate"
          end
        end

        # Override the default CSP header set by the CSP middleware
        headers['content-security-policy'] = "default-src 'none'; form-action 'none'" if request.path.start_with?(paperclip_root_url)

        headers['x-content-type-options'] = 'nosniff'

        [status, headers, response]
      end

      private

      def paperclip_root_url
        ENV.fetch('PAPERCLIP_ROOT_URL', '/system')
      end
    end
  end
end
