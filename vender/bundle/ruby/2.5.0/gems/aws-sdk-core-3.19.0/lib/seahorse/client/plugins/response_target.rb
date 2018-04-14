require 'pathname'

module Seahorse
  module Client
    module Plugins
      # @api private
      class ResponseTarget < Plugin

        # This handler is responsible for replacing the HTTP response body IO
        # object with custom targets, such as a block, or a file. It is important
        # to not write data to the custom target in the case of a non-success
        # response. We do not want to write an XML error message to someone's
        # file.
        class Handler < Client::Handler

          def call(context)
            if context.params.is_a?(Hash) && context.params[:response_target]
              target = context.params.delete(:response_target)
            else
              target = context[:response_target]
            end
            add_event_listeners(context, target) if target
            @handler.call(context)
          end

          private

          def add_event_listeners(context, target)
            handler = self
            context.http_response.on_headers(200..299) do
              context.http_response.body = handler.send(:io, target)
            end

            context.http_response.on_success(200..299) do
              body = context.http_response.body
              if ManagedFile === body && body.open?
                body.close
              end
            end

            context.http_response.on_error do
              body = context.http_response.body
              File.unlink(body) if ManagedFile === body
              context.http_response.body = StringIO.new
            end
          end

          def io(target)
            case target
            when Proc then BlockIO.new(&target)
            when String, Pathname then ManagedFile.new(target, 'w+b')
            else target
            end
          end

        end

        handler(Handler, step: :initialize, priority: 90)

      end
    end
  end
end
