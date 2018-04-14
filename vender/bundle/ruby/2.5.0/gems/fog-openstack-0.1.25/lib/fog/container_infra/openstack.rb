module Fog
  module ContainerInfra
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /v1/
      SUPPORTED_MICROVERSION = '1.3'

      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_cache_ttl,
                 :openstack_project_name, :openstack_project_id,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                 :openstack_identity_prefix

      model_path 'fog/container_infra/openstack/models'

      model       :bay
      collection  :bays
      model       :bay_model
      collection  :bay_models
      model       :certificate
      collection  :certificates
      model       :cluster
      collection  :clusters
      model       :cluster_template
      collection  :cluster_templates

      request_path 'fog/container_infra/openstack/requests'

      # Bay CRUD
      request :create_bay
      request :delete_bay
      request :get_bay
      request :list_bays
      request :update_bay

      # Bay Model CRUD
      request :create_bay_model
      request :delete_bay_model
      request :get_bay_model
      request :list_bay_models
      request :update_bay_model

      # Certificate CRUD
      request :create_certificate
      request :get_certificate

      # Cluster CRUD
      request :create_cluster
      request :delete_cluster
      request :get_cluster
      request :list_clusters
      request :update_cluster

      # Cluster Template CRUD
      request :create_cluster_template
      request :delete_cluster_template
      request :get_cluster_template
      request :list_cluster_templates
      request :update_cluster_template

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :users   => {},
              :tenants => {}
            }
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options = {})
          @openstack_username = options[:openstack_username]
          @openstack_tenant   = options[:openstack_tenant]
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])

          @auth_token = Fog::Mock.random_base64(64)
          @auth_token_expiration = (Time.now.utc + 86400).iso8601

          management_url = URI.parse(options[:openstack_auth_url])
          management_url.port = 9511
          management_url.path = '/v1'
          @openstack_management_url = management_url.to_s

          @data ||= {:users => {}}
          unless @data[:users].find { |u| u['name'] == options[:openstack_username] }
            id = Fog::Mock.random_numbers(6).to_s
            @data[:users][id] = {
              'id'       => id,
              'name'     => options[:openstack_username],
              'email'    => "#{options[:openstack_username]}@mock.com",
              'tenantId' => Fog::Mock.random_numbers(6).to_s,
              'enabled'  => true
            }
          end
        end

        def data
          self.class.data[@openstack_username]
        end

        def reset_data
          self.class.data.delete(@openstack_username)
        end

        def credentials
          {:provider                 => 'openstack',
           :openstack_auth_url       => @openstack_auth_uri.to_s,
           :openstack_auth_token     => @auth_token,
           :openstack_management_url => @openstack_management_url}
        end
      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::ContainerInfra::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type           = options[:openstack_service_type] || ['container-infra']
          @openstack_service_name           = options[:openstack_service_name]
          @openstack_endpoint_type          = options[:openstack_endpoint_type] || 'publicURL'

          @connection_options               = options[:connection_options] || {}

          authenticate
          set_api_path

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def request(options = {})
          options[:headers] = {'OpenStack-API-Version' => "container-infra #{SUPPORTED_MICROVERSION}"}
          super(options)
        end

        def set_api_path
          unless @path.match(SUPPORTED_VERSIONS)
            @path = Fog::OpenStack.get_supported_version_path(
              SUPPORTED_VERSIONS,
              @openstack_management_uri,
              @auth_token,
              @connection_options
            )
          end
        end
      end
    end
  end
end
