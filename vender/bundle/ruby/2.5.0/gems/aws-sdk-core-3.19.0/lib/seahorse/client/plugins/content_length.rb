module Seahorse
  module Client
    module Plugins
      class ContentLength < Plugin

        # @api private
        class Handler < Client::Handler

          def call(context)
            length = context.http_request.body.size
            context.http_request.headers['Content-Length'] = length
            @handler.call(context)
          end

        end

        handler(Handler, step: :sign, priority: 0)

      end
    end
  end
end
