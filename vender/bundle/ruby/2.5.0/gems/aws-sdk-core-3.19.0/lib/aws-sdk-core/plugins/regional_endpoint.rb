module Aws
  module Plugins
    # @api private
    class RegionalEndpoint < Seahorse::Client::Plugin

      # raised when region is not configured
      MISSING_REGION = 'missing required configuration option :region'

      option(:profile)

      option(:region,
        required: true,
        doc_type: String,
        docstring: <<-DOCS) do |cfg|
The AWS region to connect to.  The configured `:region` is
used to determine the service `:endpoint`. When not passed,
a default `:region` is search for in the following locations:

* `Aws.config[:region]`
* `ENV['AWS_REGION']`
* `ENV['AMAZON_REGION']`
* `ENV['AWS_DEFAULT_REGION']`
* `~/.aws/credentials`
* `~/.aws/config`
        DOCS
        resolve_region(cfg)
      end

      option(:endpoint, doc_type: String, docstring: <<-DOCS) do |cfg|
The client endpoint is normally constructed from the `:region`
option. You should only configure an `:endpoint` when connecting
to test endpoints. This should be avalid HTTP(S) URI.
        DOCS
        endpoint_prefix = cfg.api.metadata['endpointPrefix']
        if cfg.region && endpoint_prefix
          Aws::Partitions::EndpointProvider.resolve(cfg.region, endpoint_prefix)
        end
      end

      def after_initialize(client)
        if client.config.region.nil? or client.config.region == ''
          raise Errors::MissingRegionError
        end
      end

      private

      def self.resolve_region(cfg)
        keys = %w(AWS_REGION AMAZON_REGION AWS_DEFAULT_REGION)
        env_region = ENV.values_at(*keys).compact.first
        env_region = nil if env_region == ''
        cfg_region = Aws.shared_config.region(profile: cfg.profile)
        env_region || cfg_region
      end

    end
  end
end
