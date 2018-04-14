module Aws
  module S3
    module Plugins

      # Support S3 host id, more information, see:
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/troubleshooting.html#sdk-request-ids
      #
      # This plugin adds :host_id for s3 responses when available
      # @api private
      class S3HostId < Seahorse::Client::Plugin

        class Handler < Seahorse::Client::Handler

          def call(context)
            response = @handler.call(context)
            h = context.http_response.headers
            context[:s3_host_id] = h['x-amz-id-2']
            response
          end

        end

        handler(Handler, step: :sign)

      end
    end
  end
end
