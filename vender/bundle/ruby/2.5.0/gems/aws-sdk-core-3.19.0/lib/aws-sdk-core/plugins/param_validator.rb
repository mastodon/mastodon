module Aws
  module Plugins
    # @api private
    class ParamValidator < Seahorse::Client::Plugin

      option(:validate_params,
        default: true,
        doc_type: 'Boolean',
        docstring: <<-DOCS)
When `true`, request parameters are validated before
sending the request.
      DOCS

      def add_handlers(handlers, config)
        if config.validate_params
          handlers.add(Handler, step: :validate, priority: 50)
        end
      end

      class Handler < Seahorse::Client::Handler

        def call(context)
          Aws::ParamValidator.validate!(context.operation.input, context.params)
          @handler.call(context)
        end

      end

    end
  end
end
