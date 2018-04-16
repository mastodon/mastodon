module Aws
  module Plugins
    # @see Log::Formatter
    # @api private
    class Logging < Seahorse::Client::Plugin

      option(:logger,
        doc_type: 'Logger',
        docstring: <<-DOCS
The Logger instance to send log messages to.  If this option
is not set, logging will be disabled.
        DOCS
      )

      option(:log_level,
        default: :info,
        doc_type: Symbol,
        docstring: 'The log level to send messages to the `:logger` at.'
      )

      option(:log_formatter,
        doc_type: 'Aws::Log::Formatter',
        doc_default: literal('Aws::Log::Formatter.default'),
        docstring: 'The log formatter.'
      ) do |config|
        Log::Formatter.default if config.logger
      end

      def add_handlers(handlers, config)
        handlers.add(Handler, step: :validate) if config.logger
      end

      class Handler < Seahorse::Client::Handler

        # @param [RequestContext] context
        # @return [Response]
        def call(context)
          context[:logging_started_at] = Time.now
          @handler.call(context).tap do |response|
            context[:logging_completed_at] = Time.now
            log(context.config, response)
          end
        end

        private

        # @param [Configuration] config
        # @param [Response] response
        # @return [void]
        def log(config, response)
          config.logger.send(config.log_level, format(config, response))
        end

        # @param [Configuration] config
        # @param [Response] response
        # @return [String]
        def format(config, response)
          config.log_formatter.format(response)
        end

      end
    end
  end
end
