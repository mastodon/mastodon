module Aws
  module S3
    module Plugins
      # @api private
      class BucketNameRestrictions < Seahorse::Client::Plugin
        class Handler < Seahorse::Client::Handler

          def call(context)
            if context.params.key?(:bucket) && context.params[:bucket].include?('/')
              msg = ":bucket option must not contain a forward-slash (/)"
              raise ArgumentError, msg
            end
            @handler.call(context)
          end

        end

        handler(Handler)

      end
    end
  end
end
