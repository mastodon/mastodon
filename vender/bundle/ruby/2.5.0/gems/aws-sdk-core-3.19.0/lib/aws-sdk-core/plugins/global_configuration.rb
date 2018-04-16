require 'set'

module Aws
  module Plugins

    # This plugin provides the ability to provide global configuration for
    # all AWS classes or specific ones.
    #
    # ## Global AWS configuration
    #
    # You can specify global configuration defaults via `Aws.config`
    #
    #     Aws.config[:region] = 'us-west-2'
    #
    # Options applied to `Aws.config` are merged with constructed
    # service interfaces.
    #
    #     # uses the global configuration
    #     Aws::EC2.new.config.region #=> 'us-west-2'
    #
    #     # constructor args have priority over global configuration
    #     Aws::EC2.new(region: 'us-east-1').config.region #=> 'us-east-1'
    #
    # ## Service Specific Global Configuration
    #
    # Some services have very specific configuration options that are not
    # shared by other services.
    #
    #     # oops, this option is only recognized by Aws::S3
    #     Aws.config[:force_path_style] = true
    #     Aws::EC2.new
    #     #=> raises ArgumentError: invalid configuration option `:force_path_style'
    #
    # To avoid this issue, you can nest service specific options
    #
    #     Aws.config[:s3] = { force_path_style: true }
    #
    #     Aws::EC2.new # no error this time
    #     Aws::S3.new.config.force_path_style #=> true
    #
    # @api private
    class GlobalConfiguration < Seahorse::Client::Plugin

      @identifiers = Set.new()

      # @api private
      def before_initialize(client_class, options)
        # apply service specific defaults before the global aws defaults
        apply_service_defaults(client_class, options)
        apply_aws_defaults(client_class, options)
      end

      private

      def apply_service_defaults(client_class, options)
        if defaults = Aws.config[client_class.identifier]
          defaults.each do |option_name, default|
            options[option_name] = default unless options.key?(option_name)
          end
        end
      end

      def apply_aws_defaults(client_class, options)
        Aws.config.each do |option_name, default|
          next if self.class.identifiers.include?(option_name)
          next if options.key?(option_name)
          options[option_name] = default
        end
      end

      class << self

        # Registers an additional service identifier.
        # @api private
        def add_identifier(identifier)
          @identifiers << identifier
        end

        # @return [Set<String>]
        # @api private
        def identifiers
          @identifiers
        end

      end
    end
  end
end
