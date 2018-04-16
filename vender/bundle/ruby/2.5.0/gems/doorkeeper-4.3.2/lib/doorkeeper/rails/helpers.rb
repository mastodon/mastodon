module Doorkeeper
  module Rails
    module Helpers
      def doorkeeper_authorize!(*scopes)
        @_doorkeeper_scopes = scopes.presence || Doorkeeper.configuration.default_scopes

        unless valid_doorkeeper_token?
          doorkeeper_render_error
        end
      end

      def doorkeeper_unauthorized_render_options(**); end

      def doorkeeper_forbidden_render_options(**); end

      def valid_doorkeeper_token?
        doorkeeper_token && doorkeeper_token.acceptable?(@_doorkeeper_scopes)
      end

      private

      def doorkeeper_render_error
        error = doorkeeper_error
        headers.merge!(error.headers.reject { |k| k == "Content-Type" })
        doorkeeper_render_error_with(error)
      end

      def doorkeeper_render_error_with(error)
        options = doorkeeper_render_options(error) || {}
        status = doorkeeper_status_for_error(
          error, options.delete(:respond_not_found_when_forbidden)
        )
        if options.blank?
          head status
        else
          options[:status] = status
          options[:layout] = false if options[:layout].nil?
          render options
        end
      end

      def doorkeeper_error
        if doorkeeper_invalid_token_response?
          OAuth::InvalidTokenResponse.from_access_token(doorkeeper_token)
        else
          OAuth::ForbiddenTokenResponse.from_scopes(@_doorkeeper_scopes)
        end
      end

      def doorkeeper_render_options(error)
        if doorkeeper_invalid_token_response?
          doorkeeper_unauthorized_render_options(error: error)
        else
          doorkeeper_forbidden_render_options(error: error)
        end
      end

      def doorkeeper_status_for_error(error, respond_not_found_when_forbidden)
        if respond_not_found_when_forbidden && error.status == :forbidden
          :not_found
        else
          error.status
        end
      end

      def doorkeeper_invalid_token_response?
        !doorkeeper_token || !doorkeeper_token.accessible?
      end

      def doorkeeper_token
        @_doorkeeper_token ||= OAuth::Token.authenticate(
          request,
          *Doorkeeper.configuration.access_token_methods
        )
      end
    end
  end
end
