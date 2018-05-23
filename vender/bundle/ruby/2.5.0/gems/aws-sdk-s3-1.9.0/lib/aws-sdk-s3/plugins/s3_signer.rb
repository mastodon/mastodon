require 'aws-sigv4'

module Aws
  module S3
    module Plugins
      # This plugin is an implementation detail and may be modified.
      # @api private
      class S3Signer < Seahorse::Client::Plugin

        option(:signature_version, 'v4')

        option(:sigv4_signer) do |cfg|
          S3Signer.build_v4_signer(
            region: cfg.sigv4_region,
            credentials: cfg.credentials
          )
        end

        option(:sigv4_region) do |cfg|
          Aws::Partitions::EndpointProvider.signing_region(cfg.region, 's3')
        end

        def add_handlers(handlers, cfg)
          case cfg.signature_version
          when 'v4' then add_v4_handlers(handlers)
          when 's3' then add_legacy_handler(handlers)
          else
            msg = "unsupported signature version `#{cfg.signature_version}'"
            raise ArgumentError, msg
          end
        end

        def add_v4_handlers(handlers)
          handlers.add(CachedBucketRegionHandler, step: :sign, priority: 60)
          handlers.add(V4Handler, step: :sign)
          handlers.add(BucketRegionErrorHandler, step: :sign, priority: 40)
        end

        def add_legacy_handler(handlers)
          handlers.add(LegacyHandler, step: :sign)
        end

        class LegacyHandler < Seahorse::Client::Handler
          def call(context)
            LegacySigner.sign(context)
            @handler.call(context)
          end
        end

        class V4Handler < Seahorse::Client::Handler

          def call(context)
            Aws::Plugins::SignatureV4.apply_signature(
              context: context,
              signer: sigv4_signer(context)
            )
            @handler.call(context)
          end

          private

          def sigv4_signer(context)
            # If the client was configured with the wrong region,
            # we have to build a new signer.
            if
              context[:cached_sigv4_region] &&
              context[:cached_sigv4_region] != context.config.sigv4_signer.region
            then
              S3Signer.build_v4_signer(
                region: context[:cached_sigv4_region],
                credentials: context.config.credentials
              )
            else
              context.config.sigv4_signer
            end
          end

        end

        # This handler will update the http endpoint when the bucket region
        # is known/cached.
        class CachedBucketRegionHandler < Seahorse::Client::Handler

          def call(context)
            bucket = context.params[:bucket]
            check_for_cached_region(context, bucket) if bucket
            @handler.call(context)
          end

          private

          def check_for_cached_region(context, bucket)
            cached_region = S3::BUCKET_REGIONS[bucket]
            if cached_region && cached_region != context.config.region
              context.http_request.endpoint.host = S3Signer.new_hostname(context, cached_region)
              context[:cached_sigv4_region] = cached_region
            end
          end

        end

        # This handler detects when a request fails because of a mismatched bucket
        # region. It follows up by making a request to determine the correct
        # region, then finally a version 4 signed request against the correct
        # regional endpoint.
        class BucketRegionErrorHandler < Seahorse::Client::Handler

          def call(context)
            response = @handler.call(context)
            handle_region_errors(response)
          end

          private

          def handle_region_errors(response)
            if wrong_sigv4_region?(response)
              get_region_and_retry(response.context)
            else
              response
            end
          end

          def get_region_and_retry(context)
            actual_region = context.http_response.headers['x-amz-bucket-region']
            actual_region ||= region_from_body(context.http_response.body_contents)
            update_bucket_cache(context, actual_region)
            log_warning(context, actual_region)
            resign_with_new_region(context, actual_region)
            @handler.call(context)
          end

          def update_bucket_cache(context, actual_region)
            S3::BUCKET_REGIONS[context.params[:bucket]] = actual_region
          end

          def wrong_sigv4_region?(resp)
            resp.context.http_response.status_code == 400 &&
            (
              resp.context.http_response.headers['x-amz-bucket-region'] ||
              resp.context.http_response.body_contents.match(/<Region>.+?<\/Region>/)
            )
          end

          def resign_with_new_region(context, actual_region)
            context.http_response.body.truncate(0)
            context.http_request.endpoint.host = S3Signer.new_hostname(context, actual_region)
            Aws::Plugins::SignatureV4.apply_signature(
              context: context,
              signer: S3Signer.build_v4_signer(
                region: actual_region,
                credentials: context.config.credentials
              )
            )
          end

          def region_from_body(body)
            region = body.match(/<Region>(.+?)<\/Region>/)[1]
            if region.nil? || region == ""
              raise "couldn't get region from body: #{body}"
            else
              region
            end
          end

          def log_warning(context, actual_region)
            msg = "S3 client configured for #{context.config.region.inspect} " +
              "but the bucket #{context.params[:bucket].inspect} is in " +
              "#{actual_region.inspect}; Please configure the proper region " +
              "to avoid multiple unnecessary redirects and signing attempts\n"
            if logger = context.config.logger
              logger.warn(msg)
            else
              warn(msg)
            end
          end

        end

        class << self

          # @option options [required, String] :region
          # @option options [required, #credentials] :credentials
          # @api private
          def build_v4_signer(options = {})
            Aws::Sigv4::Signer.new({
              service: 's3',
              region: options[:region],
              credentials_provider: options[:credentials],
              uri_escape_path: false,
              unsigned_headers: ['content-length', 'x-amzn-trace-id'],
            })
          end

          def new_hostname(context, region)
            bucket = context.params[:bucket]
            if region == 'us-east-1'
              "#{bucket}.s3.amazonaws.com"
            else
              endpoint = Aws::Partitions::EndpointProvider.resolve(region, 's3')
              bucket + '.' + URI.parse(endpoint).host
            end
          end

        end
      end
    end
  end
end
