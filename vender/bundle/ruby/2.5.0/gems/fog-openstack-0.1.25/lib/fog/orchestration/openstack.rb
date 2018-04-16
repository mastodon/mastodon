

module Fog
  module Orchestration
    class OpenStack < Fog::Service
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

      model_path 'fog/orchestration/openstack/models'
      model       :stack
      collection  :stacks

      model :resource
      collection :resources

      collection :resource_schemas

      model :event
      collection :events

      model :template
      collection :templates

      request_path 'fog/orchestration/openstack/requests'
      request :abandon_stack
      request :build_info
      request :create_stack
      request :delete_stack
      request :get_stack_template
      request :list_events
      request :list_resource_events
      request :list_resource_types
      request :list_resources
      request :list_stack_data
      request :list_stack_data_detailed
      request :list_stack_events
      request :preview_stack
      request :show_event_details
      request :show_resource_data
      request :show_resource_metadata
      request :show_resource_schema
      request :show_resource_template
      request :show_stack_details
      request :update_stack
      request :patch_stack
      request :validate_template
      request :cancel_update

      module Reflectable
        REFLECTION_REGEX = /\/stacks\/(\w+)\/([\w|-]+)\/resources\/(\w+)/

        def resource
          @resource ||= service.resources.get(r[3], stack)
        end

        def stack
          @stack ||= service.stacks.get(r[1], r[2])
        end

        private

        def reflection
          @reflection ||= REFLECTION_REGEX.match(links[0]['href'])
        end
        alias r reflection
      end

      class Mock
        attr_reader :auth_token
        attr_reader :auth_token_expiration
        attr_reader :current_user
        attr_reader :current_tenant

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :stacks => {}
            }
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options = {})
          @openstack_username = options[:openstack_username]
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])

          @current_tenant = options[:openstack_tenant]

          @auth_token = Fog::Mock.random_base64(64)
          @auth_token_expiration = (Time.now.utc + 86400).iso8601

          management_url = URI.parse(options[:openstack_auth_url])
          management_url.port = 8774
          management_url.path = '/v1'
          @openstack_management_url = management_url.to_s

          identity_public_endpoint = URI.parse(options[:openstack_auth_url])
          identity_public_endpoint.port = 5000
          @openstack_identity_public_endpoint = identity_public_endpoint.to_s
        end

        def data
          self.class.data["#{@openstack_username}-#{@current_tenant}"]
        end

        def reset_data
          self.class.data.delete("#{@openstack_username}-#{@current_tenant}")
        end

        def credentials
          {:provider                    => 'openstack',
           :openstack_auth_url          => @openstack_auth_uri.to_s,
           :openstack_auth_token        => @auth_token,
           :openstack_management_url    => @openstack_management_url,
           :openstack_identity_endpoint => @openstack_identity_public_endpoint}
        end
      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Orchestration::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_identity_service_type = options[:openstack_identity_service_type] || 'identity'

          @openstack_service_type           = options[:openstack_service_type] || ['orchestration']
          @openstack_service_name           = options[:openstack_service_name]

          @connection_options               = options[:connection_options] || {}

          authenticate

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end
      end
    end
  end
end
