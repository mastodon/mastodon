module Seahorse
  module Client
    module Plugins
      # @api private
      class Logging < Plugin

        option(:logger,
          default: nil,
          doc_type: 'Logger',
          docstring: <<-DOCS)
The Logger instance to send log messages to. If this option
is not set, logging is disabled.
          DOCS

        option(:log_level,
          default: :info,
          doc_type: Symbol,
          docstring: 'The log level to send messages to the logger at.')

        option(:log_formatter,
          default: Seahorse::Client::Logging::Formatter.default,
          doc_default: 'Aws::Log::Formatter.default',
          doc_type: 'Aws::Log::Formatter',
          docstring: 'The log formatter.')

        def add_handlers(handlers, config)
          if config.logger
            handlers.add(Client::Logging::Handler, step: :validate)
          end
        end

      end
    end
  end
end
