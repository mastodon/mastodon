require 'uri'
require 'openssl'

module Aws
  module S3
    module Plugins
      class SseCpk < Seahorse::Client::Plugin

        option(:require_https_for_sse_cpk,
          default: true,
          doc_type: 'Boolean',
          docstring: <<-DOCS)
When `true`, the endpoint **must** be HTTPS for all operations
where server-side-encryption is used with customer-provided keys.
This should only be disabled for local testing.
          DOCS

        class Handler < Seahorse::Client::Handler

          def call(context)
            compute_key_md5(context)
            @handler.call(context)
          end

          private

          def compute_key_md5(context)
            params = context.params
            if key = params[:sse_customer_key]
              require_https(context)
              params[:sse_customer_key] = base64(key)
              params[:sse_customer_key_md5] = base64(md5(key))
            end
            if key = params[:copy_source_sse_customer_key]
              require_https(context)
              params[:copy_source_sse_customer_key] = base64(key)
              params[:copy_source_sse_customer_key_md5] = base64(md5(key))
            end
          end

          def require_https(context)
            unless URI::HTTPS === context.config.endpoint
              msg = <<-MSG.strip.gsub("\n", ' ')
                Attempting to send customer-provided-keys for S3
                server-side-encryption over HTTP; Please configure a HTTPS
                endpoint. If you are attempting to use a test endpoint,
                you can disable this check via `:require_https_for_sse_cpk`
              MSG
              raise ArgumentError, msg
            end
          end

          def md5(str)
            OpenSSL::Digest::MD5.digest(str)
          end

          def base64(str)
            Base64.encode64(str).strip
          end

        end

        handler(Handler, step: :initialize)

      end
    end
  end
end
