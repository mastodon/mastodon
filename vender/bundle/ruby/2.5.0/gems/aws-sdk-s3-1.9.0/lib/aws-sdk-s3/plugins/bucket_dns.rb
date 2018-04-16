module Aws
  module S3
    module Plugins

      # Amazon S3 requires DNS style addressing for buckets outside of
      # the classic region when possible.
      class BucketDns < Seahorse::Client::Plugin

        # When set to `false` DNS compatible bucket names are moved from
        # the request URI path to the host as a subdomain, unless the request
        # is using SSL and the bucket name contains a dot.
        #
        # When set to `true`, the bucket name is always forced to be part
        # of the request URI path.  This will not work with buckets outside
        # the classic region.
        option(:force_path_style,
          default: false,
          doc_type: 'Boolean',
          docstring: <<-DOCS)
When set to `true`, the bucket name is always left in the
request URI and never moved to the host as a sub-domain.
          DOCS

        def add_handlers(handlers, config)
          handlers.add(Handler) unless config.force_path_style
        end

        # @api private
        class Handler < Seahorse::Client::Handler

          def call(context)
            move_dns_compat_bucket_to_subdomain(context)
            @handler.call(context)
          end

          private

          def move_dns_compat_bucket_to_subdomain(context)
            bucket_name = context.params[:bucket]
            endpoint = context.http_request.endpoint
            if
              bucket_name &&
              BucketDns.dns_compatible?(bucket_name, https?(endpoint)) &&
              context.operation_name.to_s != 'get_bucket_location'
            then
              move_bucket_to_subdomain(bucket_name, endpoint)
            end
          end

          def move_bucket_to_subdomain(bucket_name, endpoint)
            endpoint.host = "#{bucket_name}.#{endpoint.host}"
            path = endpoint.path.sub("/#{bucket_name}", '')
            path = "/#{path}" unless path.match(/^\//)
            endpoint.path = path
          end

          def https?(uri)
            uri.scheme == 'https'
          end

        end

        class << self

          # @param [String] bucket_name
          # @param [Boolean] ssl
          # @return [Boolean]
          def dns_compatible?(bucket_name, ssl)
            if valid_subdomain?(bucket_name)
              bucket_name.match(/\./) && ssl ? false : true
            else
              false
            end
          end

          private

          def valid_subdomain?(bucket_name)
            bucket_name.size < 64 &&
            bucket_name =~ /^[a-z0-9][a-z0-9.-]+[a-z0-9]$/ &&
            bucket_name !~ /(\d+\.){3}\d+/ &&
            bucket_name !~ /[.-]{2}/
          end

        end
      end
    end
  end
end
