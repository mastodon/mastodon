

module Fog
  module Identity
    class OpenStack < Fog::Service
      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url, :persistent,
                 :openstack_service_type, :openstack_service_name, :openstack_tenant,
                 :openstack_endpoint_type, :openstack_region, :openstack_domain_id,
                 :openstack_project_name, :openstack_domain_name,
                 :openstack_user_domain, :openstack_project_domain,
                 :openstack_user_domain_id, :openstack_project_domain_id,
                 :openstack_api_key, :openstack_current_user_id, :openstack_userid, :openstack_username,
                 :current_user, :current_user_id, :current_tenant, :openstack_cache_ttl,
                 :provider, :openstack_identity_prefix, :openstack_endpoint_path_matches

      # Fog::Identity::OpenStack.new() will return a Fog::Identity::OpenStack::V3 by default
      def self.new(args = {})
        version = '3'
        url = Fog.credentials[:openstack_auth_url] || args[:openstack_auth_url]
        if url
          uri = URI(url)
          version = '2.0' if uri.path =~ /v2\.0/
        end

        service = case version
                  when '2.0'
                    Fog::Identity::OpenStack::V2.new(args)
                  else
                    Fog::Identity::OpenStack::V3.new(args)
                  end
        service
      end

      class Mock
        attr_reader :config

        def initialize(options = {})
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
          @config = options
        end
      end

      class Real
        include Fog::OpenStack::Core

        DEFAULT_SERVICE_TYPE_V3 = %w(identity_v3 identityv3 identity).collect(&:freeze).freeze
        DEFAULT_SERVICE_TYPE    = %w(identity).collect(&:freeze).freeze

        def self.not_found_class
          Fog::Identity::OpenStack::NotFound
        end

        def initialize(options = {})
          if options.respond_to?(:config_service?) && options.config_service?
            configure(options)
            return
          end

          initialize_identity(options)

          @openstack_service_type   = options[:openstack_service_type] || default_service_type(options)
          @openstack_service_name   = options[:openstack_service_name]

          @connection_options       = options[:connection_options] || {}

          @openstack_endpoint_type  = options[:openstack_endpoint_type] || 'adminURL'
          initialize_endpoint_path_matches(options)

          authenticate

          if options[:openstack_identity_prefix]
            @path = "/#{options[:openstack_identity_prefix]}/#{@path}"
          end

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def config_service?
          true
        end

        def config
          self
        end

        private

        def default_service_type(options)
          unless options[:openstack_identity_prefix]
            if @openstack_auth_uri.path =~ %r{/v3} ||
               (options[:openstack_endpoint_path_matches] && options[:openstack_endpoint_path_matches] =~ '/v3')
              return DEFAULT_SERVICE_TYPE_V3
            end
          end
          DEFAULT_SERVICE_TYPE
        end

        def initialize_endpoint_path_matches(options)
          if options[:openstack_endpoint_path_matches]
            @openstack_endpoint_path_matches = options[:openstack_endpoint_path_matches]
          end
        end

        def configure(source)
          source.instance_variables.each do |v|
            instance_variable_set(v, source.instance_variable_get(v))
          end
        end
      end
    end
  end
end
