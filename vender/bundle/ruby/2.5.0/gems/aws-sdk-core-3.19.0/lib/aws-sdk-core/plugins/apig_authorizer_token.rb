module Aws
  module Plugins

    # apply APIG custom authorizer token to
    # operations with 'authtype' of 'custom' only
    class APIGAuthorizerToken < Seahorse::Client::Plugin

      option(:authorizer_token, default: nil)

      def add_handlers(handlers, config)
        handlers.add(AuthTokenHandler, step: :sign)
      end

      # @api private
      class AuthTokenHandler < Seahorse::Client::Handler

        def call(context)
          if context.operation['authtype'] == 'custom' &&
            context.config.authorizer_token &&
            context.authorizer.placement[:location] == 'header'

            header = context.authorizer.placement[:name]
            context.http_request.headers[header] = context.config.authorizer_token
          end
          @handler.call(context)
        end
      end
    end
  end
end
