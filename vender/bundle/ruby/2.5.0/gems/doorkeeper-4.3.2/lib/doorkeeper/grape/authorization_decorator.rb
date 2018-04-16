module Doorkeeper
  module Grape
    class AuthorizationDecorator < SimpleDelegator
      def parameters
        params
      end

      def authorization
        env = __getobj__.env
        env['HTTP_AUTHORIZATION'] ||
          env['X-HTTP_AUTHORIZATION'] ||
          env['X_HTTP_AUTHORIZATION'] ||
          env['REDIRECT_X_HTTP_AUTHORIZATION']
      end
    end
  end
end
