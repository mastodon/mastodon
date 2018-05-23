module Aws
  module Plugins
    # @api private
    class HelpfulSocketErrors < Seahorse::Client::Plugin

      class Handler < Seahorse::Client::Handler

        # Wrap `SocketError` errors with `Aws::Errors::NoSuchEndpointError`
        def call(context)
          response = @handler.call(context)
          response.context.http_response.on_error do |error|
            if socket_endpoint_error?(error)
              response.error = no_such_endpoint_error(context, error)
            end
          end
          response
        end

        private

        def socket_endpoint_error?(error)
          Seahorse::Client::NetworkingError === error &&
          SocketError === error.original_error &&
          error.original_error.message.match(/failed to open tcp connection/i) &&
          error.original_error.message.match(/getaddrinfo: nodename nor servname provided, or not known/i)
        end

        def no_such_endpoint_error(context, error)
          Errors::NoSuchEndpointError.new({
            context: context,
            original_error: error.original_error,
          })
        end

      end

      handle(Handler, step: :sign)

    end
  end
end
