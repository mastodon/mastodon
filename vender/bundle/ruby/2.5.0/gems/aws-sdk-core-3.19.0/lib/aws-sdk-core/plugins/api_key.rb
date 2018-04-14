module Aws
  module Plugins

    # Provide support for `api_key` parameter for `api-gateway` protocol
    # specific `api-gateway` protocol gems' user-agent
    class ApiKey < Seahorse::Client::Plugin

      option(:api_key,
        default: nil,
        doc_type: 'String',
        docstring: <<-DOCS)
When provided, `x-api-key` header will be injected with the value provided.
        DOCS

      def add_handlers(handlers, config)
        handlers.add(OptionHandler, step: :initialize)
        handlers.add(ApiKeyHandler, step: :build, priority: 0)
      end

      # @api private
      class OptionHandler < Seahorse::Client::Handler
        def call(context)
          if context.operation.require_apikey
            api_key = context.params.delete(:api_key)
            api_key = context.config.api_key if api_key.nil?
            context[:api_key] = api_key
          end

          @handler.call(context)
        end

      end

      # @api private
      class ApiKeyHandler < Seahorse::Client::Handler

        def call(context)
          if context[:api_key]
            apply_api_key(context)
          end
          @handler.call(context)
        end

        private

        def apply_api_key(context)
          context.http_request.headers['x-api-key'] = context[:api_key]
        end
      end
    end
  end
end
