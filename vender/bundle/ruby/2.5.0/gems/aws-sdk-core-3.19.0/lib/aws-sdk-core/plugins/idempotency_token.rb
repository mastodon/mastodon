require 'securerandom'

module Aws
  module Plugins

    # Provides support for auto filling operation parameters
    # that enabled with `idempotencyToken` trait  with random UUID v4
    # when no value is provided
    # @api private
    class IdempotencyToken < Seahorse::Client::Plugin

      # @api private
      class Handler < Seahorse::Client::Handler

        def call(context)
          auto_fill(context.params, context.operation.input)
          @handler.call(context)
        end

        private

        def auto_fill(params, ref)
          ref.shape.members.each do |name, member_ref|
            if member_ref['idempotencyToken']
              params[name] ||= SecureRandom.uuid
            end
          end
        end

      end

      handler(Handler, step: :initialize)

    end
  end
end
