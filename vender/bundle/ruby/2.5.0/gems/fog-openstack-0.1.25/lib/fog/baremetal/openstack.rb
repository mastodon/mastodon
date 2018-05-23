

module Fog
  module Baremetal
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /(.)*/

      requires :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_cache_ttl,
                 :openstack_project_name, :openstack_project_id,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id

      ## MODELS
      #
      model_path 'fog/baremetal/openstack/models'
      model       :chassis
      collection  :chassis_collection
      model       :driver
      collection  :drivers
      model       :node
      collection  :nodes
      model       :port
      collection  :ports

      ## REQUESTS
      #
      request_path 'fog/baremetal/openstack/requests'

      # Node requests
      request :create_node
      request :delete_node
      request :get_node
      request :list_nodes
      request :list_nodes_detailed
      request :patch_node
      request :set_node_power_state
      request :set_node_provision_state
      request :set_node_maintenance
      request :unset_node_maintenance

      # Chassis requests
      request :create_chassis
      request :delete_chassis
      request :get_chassis
      request :list_chassis
      request :list_chassis_detailed
      request :patch_chassis

      # Driver requests
      request :get_driver
      request :get_driver_properties
      request :list_drivers

      # Port requests
      request :create_port
      request :delete_port
      request :get_port
      request :list_ports
      request :list_ports_detailed
      request :patch_port

      ## TODO not implemented API requests:
      ## Chassis
      # request :list_chassis_nodes
      # request :list_chassis_nodes_details

      ## Node requests
      # request :validate_node
      # request :get_boot_device
      # request :set_boot_device
      # request :list_supported_boot_devices
      # request :list_node_states
      # request :get_console_info
      # request :change_console_state
      # request :get_vendor_passthru_methods

      ## Driver requests
      # request :get_vendor_passthru_methods

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            chassis_uuid = Fog::UUID.uuid
            instance_uuid = Fog::UUID.uuid
            node_uuid = Fog::UUID.uuid

            hash[key] = {
              :chassis_collection => [
                {
                  "created_at"  => "2000-01-01T12:00:00",
                  "description" => "Sample chassis",
                  "extra"       => {},
                  "links"       => [
                    {
                      "href" => "http://localhost:6385/v1/chassis/eaaca217-e7d8-47b4-bb41-3f99f20eed89",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://localhost:6385/chassis/eaaca217-e7d8-47b4-bb41-3f99f20eed89",
                      "rel"  => "bookmark"
                    }
                  ],
                  "nodes"       => [
                    {
                      "href" => "http://localhost:6385/v1/chassis/eaaca217-e7d8-47b4-bb41-3f99f20eed89/nodes",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://localhost:6385/chassis/eaaca217-e7d8-47b4-bb41-3f99f20eed89/nodes",
                      "rel"  => "bookmark"
                    }
                  ],
                  "updated_at"  => "2000-01-01T12:00:00",
                  "uuid"        => chassis_uuid
                }
              ],
              :drivers            => [
                {
                  "hosts" => [
                    "fake-host"
                  ],
                  "name"  => "sample-driver"
                }
              ],
              :nodes              => [{
                "chassis_uuid"           => chassis_uuid,
                "console_enabled"        => false,
                "created_at"             => "2000-01-01T12:00:00",
                "driver"                 => "sample-driver",
                "driver_info"            => {},
                "extra"                  => {},
                "instance_info"          => {},
                "instance_uuid"          => instance_uuid,
                "last_error"             => nil,
                "links"                  => [
                  {
                    "href" => "http://localhost:6385/v1/nodes/1be26c0b-03f2-4d2e-ae87-c02d7f33c123",
                    "rel"  => "self"
                  },
                  {
                    "href" => "http://localhost:6385/nodes/1be26c0b-03f2-4d2e-ae87-c02d7f33c123",
                    "rel"  => "bookmark"
                  }
                ],
                "maintenance"            => false,
                "maintenance_reason"     => nil,
                "ports"                  => [
                  {
                    "href" => "http://localhost:6385/v1/nodes/1be26c0b-03f2-4d2e-ae87-c02d7f33c123/ports",
                    "rel"  => "self"
                  },
                  {
                    "href" => "http://localhost:6385/nodes/1be26c0b-03f2-4d2e-ae87-c02d7f33c123/ports",
                    "rel"  => "bookmark"
                  }
                ],
                "power_state"            => "power on",
                "properties"             => {
                  "cpus"      => "1",
                  "local_gb"  => "10",
                  "memory_mb" => "1024"
                },
                "provision_state"        => "active",
                "provision_updated_at"   => "2000-01-01T12:00:00",
                "reservation"            => nil,
                "target_power_state"     => nil,
                "target_provision_state" => nil,
                "updated_at"             => "2000-01-01T12:00:00",
                "uuid"                   => node_uuid
              }],
              :ports              => [{
                "address"    => "fe:54:00:77:07:d9",
                "created_at" => "2014-12-23T19:35:30.734116",
                "extra"      => {
                  "foo" => "bar"
                },
                "links"      => [
                  {
                    "href" => "http://localhost:6385/v1/ports/27e3153e-d5bf-4b7e-b517-fb518e17f34c",
                    "rel"  => "self"
                  },
                  {
                    "href" => "http://localhost:6385/ports/27e3153e-d5bf-4b7e-b517-fb518e17f34c",
                    "rel"  => "bookmark"
                  }
                ],
                "node_uuid"  => "7ae81bb3-dec3-4289-8d6c-da80bd8001ae",
                "updated_at" => "2014-12-23T19:35:30.734119",
                "uuid"       => "27e3153e-d5bf-4b7e-b517-fb518e17f34c"
              }]
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
          management_url.port = 9292
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
           :openstack_region         => @openstack_region,
           :openstack_management_url => @openstack_management_url}
        end
      end

      class Real
        include Fog::OpenStack::Core

        # NOTE: uncommenting this should be treated as api-change!
        # def self.not_found_class
        #   Fog::Baremetal::OpenStack::NotFound
        # end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type  = options[:openstack_service_type] || ['baremetal']
          @openstack_service_name  = options[:openstack_service_name]

          @connection_options = options[:connection_options] || {}

          authenticate
          set_api_path

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        private

        def set_api_path
          unless @path.match(SUPPORTED_VERSIONS)
            @path = "/" + Fog::OpenStack.get_supported_version(SUPPORTED_VERSIONS,
                                                               @openstack_management_uri,
                                                               @auth_token,
                                                               @connection_options)
          end
        end
      end
    end
  end
end
