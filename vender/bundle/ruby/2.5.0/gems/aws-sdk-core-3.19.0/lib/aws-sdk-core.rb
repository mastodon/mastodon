require 'aws-partitions'
require 'seahorse'
require 'jmespath'

require_relative 'aws-sdk-core/deprecations'

# credential providers

require_relative 'aws-sdk-core/credential_provider'
require_relative 'aws-sdk-core/refreshing_credentials'
require_relative 'aws-sdk-core/assume_role_credentials'
require_relative 'aws-sdk-core/credentials'
require_relative 'aws-sdk-core/credential_provider_chain'
require_relative 'aws-sdk-core/ecs_credentials'
require_relative 'aws-sdk-core/instance_profile_credentials'
require_relative 'aws-sdk-core/shared_credentials'

# client modules

require_relative 'aws-sdk-core/client_stubs'
require_relative 'aws-sdk-core/eager_loader'
require_relative 'aws-sdk-core/errors'
require_relative 'aws-sdk-core/pageable_response'
require_relative 'aws-sdk-core/pager'
require_relative 'aws-sdk-core/param_converter'
require_relative 'aws-sdk-core/param_validator'
require_relative 'aws-sdk-core/shared_config'
require_relative 'aws-sdk-core/structure'
require_relative 'aws-sdk-core/type_builder'
require_relative 'aws-sdk-core/util'

# resource classes

require_relative 'aws-sdk-core/resources/collection'

# logging

require_relative 'aws-sdk-core/log/formatter'
require_relative 'aws-sdk-core/log/param_filter'
require_relative 'aws-sdk-core/log/param_formatter'

# stubbing

require_relative 'aws-sdk-core/stubbing/empty_stub'
require_relative 'aws-sdk-core/stubbing/data_applicator'
require_relative 'aws-sdk-core/stubbing/stub_data'
require_relative 'aws-sdk-core/stubbing/xml_error'

# stubbing protocols

require_relative 'aws-sdk-core/stubbing/protocols/ec2'
require_relative 'aws-sdk-core/stubbing/protocols/json'
require_relative 'aws-sdk-core/stubbing/protocols/query'
require_relative 'aws-sdk-core/stubbing/protocols/rest'
require_relative 'aws-sdk-core/stubbing/protocols/rest_json'
require_relative 'aws-sdk-core/stubbing/protocols/rest_xml'
require_relative 'aws-sdk-core/stubbing/protocols/api_gateway'

# protocols

require_relative 'aws-sdk-core/rest'
require_relative 'aws-sdk-core/xml'
require_relative 'aws-sdk-core/json'

# aws-sdk-sts is vendored to support Aws::AssumeRoleCredentials

require 'aws-sdk-sts'

module Aws

  CORE_GEM_VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  @config = {}

  class << self

    # @api private
    def shared_config
      enabled = ENV["AWS_SDK_CONFIG_OPT_OUT"] ? false : true
      @shared_config ||= SharedConfig.new(config_enabled: enabled)
    end

    # @return [Hash] Returns a hash of default configuration options shared
    #   by all constructed clients.
    attr_reader :config

    # @param [Hash] config
    def config=(config)
      if Hash === config
        @config = config
      else
        raise ArgumentError, 'configuration object must be a hash'
      end
    end

    # @see (Aws::Partitions.partition)
    def partition(partition_name)
      Aws::Partitions.partition(partition_name)
    end

    # @see (Aws::Partitions.partitions)
    def partitions
      Aws::Partitions.partitions
    end

    # The SDK ships with a ca certificate bundle to use when verifying SSL
    # peer certificates. By default, this cert bundle is *NOT* used. The
    # SDK will rely on the default cert available to OpenSSL. This ensures
    # the cert provided by your OS is used.
    #
    # For cases where the default cert is unavailable, e.g. Windows, you
    # can call this method.
    #
    #     Aws.use_bundled_cert!
    #
    # @return [String] Returns the path to the bundled cert.
    def use_bundled_cert!
      config.delete(:ssl_ca_directory)
      config.delete(:ssl_ca_store)
      config[:ssl_ca_bundle] = File.expand_path(File.join(
        File.dirname(__FILE__),
        '..',
        'ca-bundle.crt'
      ))
    end

    # Close any long-lived connections maintained by the SDK's internal
    # connection pool.
    #
    # Applications that rely heavily on the `fork()` system call on POSIX systems
    # should call this method in the child process directly after fork to ensure
    # there are no race conditions between the parent
    # process and its children
    # for the pooled TCP connections.
    #
    # Child processes that make multi-threaded calls to the SDK should block on
    # this call before beginning work.
    #
    # @return [nil]
    def empty_connection_pools!
      Seahorse::Client::NetHttp::ConnectionPool.pools.each do |pool|
        pool.empty!
      end
    end

    # @api private
    def eager_autoload!(*args)
      msg = 'Aws.eager_autoload is no longer needed, usage of '
      msg << 'autoload has been replaced with require statements'
      warn(msg)
    end

  end
end
