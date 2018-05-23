module Aws
  module Plugins

    # Converts input value to JSON Syntax for members with jsonvalue trait
    class JsonvalueConverter < Seahorse::Client::Plugin

      # @api private
      class Handler < Seahorse::Client::Handler

        def call(context)
          context.operation.input.shape.members.each do |m, ref|
            if ref['jsonvalue']
              param_value = context.params[m]
              unless param_value.respond_to?(:to_json)
                raise ArgumentError, "The value of params[#{m}] is not JSON serializable."
              end
              context.params[m] = param_value.to_json
            end
          end
          @handler.call(context)
        end

      end

      handler(Handler, step: :initialize)
    end

  end
end
