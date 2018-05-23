module Fog
  module Compute
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /v2\.0|v2\.1/
      SUPPORTED_MICROVERSION = '2.15'.freeze

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

      ## MODELS
      #
      model_path 'fog/compute/openstack/models'
      model       :aggregate
      collection  :aggregates
      model       :availability_zone
      collection  :availability_zones
      model       :server
      collection  :servers
      model       :service
      collection  :services
      model       :image
      collection  :images
      model       :flavor
      collection  :flavors
      model       :metadatum
      collection  :metadata
      model       :address
      collection  :addresses
      model       :security_group
      collection  :security_groups
      model       :security_group_rule
      collection  :security_group_rules
      model       :key_pair
      collection  :key_pairs
      model       :tenant
      collection  :tenants
      model       :volume
      collection  :volumes
      model       :volume_attachment
      collection  :volume_attachments
      model       :network
      collection  :networks
      model       :snapshot
      collection  :snapshots
      model       :host
      collection  :hosts
      model       :server_group
      collection  :server_groups
      model       :os_interface
      collection  :os_interfaces

      ## REQUESTS
      #
      request_path 'fog/compute/openstack/requests'

      # Aggregate CRUD
      request :list_aggregates
      request :create_aggregate
      request :update_aggregate
      request :get_aggregate
      request :update_aggregate
      request :update_aggregate_metadata
      request :add_aggregate_host
      request :remove_aggregate_host
      request :delete_aggregate

      # Server CRUD
      request :list_servers
      request :list_servers_detail
      request :create_server
      request :get_server_details
      request :get_server_password
      request :update_server
      request :delete_server

      # Server Actions
      request :server_actions
      request :server_action
      request :reboot_server
      request :rebuild_server
      request :resize_server
      request :confirm_resize_server
      request :revert_resize_server
      request :pause_server
      request :unpause_server
      request :suspend_server
      request :resume_server
      request :start_server
      request :stop_server
      request :rescue_server
      request :change_server_password
      request :add_fixed_ip
      request :remove_fixed_ip
      request :server_diagnostics
      request :boot_from_snapshot
      request :reset_server_state
      request :add_security_group
      request :remove_security_group
      request :shelve_server
      request :unshelve_server
      request :shelve_offload_server

      # Server Extenstions
      request :get_console_output
      request :get_vnc_console
      request :live_migrate_server
      request :migrate_server
      request :evacuate_server

      # Service CRUD
      request :list_services
      request :enable_service
      request :disable_service
      request :disable_service_log_reason
      request :delete_service

      # Image CRUD
      request :list_images
      request :list_images_detail
      request :create_image
      request :get_image_details
      request :delete_image

      # Flavor CRUD
      request :list_flavors
      request :list_flavors_detail
      request :get_flavor_details
      request :create_flavor
      request :delete_flavor

      # Flavor Actions
      request :get_flavor_metadata
      request :create_flavor_metadata
      request :update_flavor_metadata
      request :delete_flavor_metadata

      # Flavor Access
      request :add_flavor_access
      request :remove_flavor_access
      request :list_tenants_with_flavor_access

      # Hypervisor
      request :get_hypervisor_statistics
      request :get_hypervisor
      request :list_hypervisors
      request :list_hypervisors_detail
      request :list_hypervisor_servers

      # Metadata
      request :list_metadata
      request :get_metadata
      request :set_metadata
      request :update_metadata
      request :delete_metadata

      # Metadatam
      request :delete_meta
      request :update_meta

      # Address
      request :list_addresses
      request :list_address_pools
      request :list_all_addresses
      request :list_private_addresses
      request :list_public_addresses
      request :get_address
      request :allocate_address
      request :associate_address
      request :release_address
      request :disassociate_address

      # Security Group
      request :list_security_groups
      request :get_security_group
      request :create_security_group
      request :create_security_group_rule
      request :delete_security_group
      request :delete_security_group_rule
      request :get_security_group_rule

      # Key Pair
      request :list_key_pairs
      request :get_key_pair
      request :create_key_pair
      request :delete_key_pair

      # Tenant
      request :list_tenants
      request :set_tenant
      request :get_limits

      # Volume
      request :list_volumes
      request :list_volumes_detail
      request :create_volume
      request :get_volume_details
      request :delete_volume
      request :attach_volume
      request :detach_volume
      request :get_server_volumes
      request :list_volume_attachments

      # Snapshot
      request :create_snapshot
      request :list_snapshots
      request :list_snapshots_detail
      request :get_snapshot_details
      request :delete_snapshot

      # Usage
      request :list_usages
      request :get_usage

      # Quota
      request :get_quota
      request :get_quota_defaults
      request :update_quota

      # Hosts
      request :list_hosts
      request :get_host_details

      # Zones
      request :list_zones
      request :list_zones_detailed
      request :list_availability_zones

      # Server Group
      request :list_server_groups
      request :get_server_group
      request :create_server_group
      request :delete_server_group

      # Server Os Interfaces
      request :list_os_interfaces
      request :get_os_interface
      request :create_os_interface
      request :delete_os_interface

      class Mock
        attr_reader :auth_token
        attr_reader :auth_token_expiration
        attr_reader :current_user
        attr_reader :current_tenant

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :last_modified             => {
                :images          => {},
                :servers         => {},
                :key_pairs       => {},
                :security_groups => {},
                :addresses       => {}
              },
              :aggregates                => [{
                "availability_zone" => "nova",
                "created_at"        => "2012-11-16T06:22:23.032493",
                "deleted"           => false,
                "deleted_at"        => nil,
                "id"                => 1,
                "name"              => "name",
                "updated_at"        => nil
              }],
              :images                    => {
                "0e09fbd6-43c5-448a-83e9-0d3d05f9747e" => {
                  "id"       => "0e09fbd6-43c5-448a-83e9-0d3d05f9747e",
                  "name"     => "cirros-0.3.0-x86_64-blank",
                  'progress' => 100,
                  'status'   => "ACTIVE",
                  'updated'  => "",
                  'minRam'   => 0,
                  'minDisk'  => 0,
                  'metadata' => {},
                  'links'    => [{"href" => "http://nova1:8774/v1.1/admin/images/1", "rel" => "self"},
                                 {"href" => "http://nova1:8774/admin/images/2", "rel" => "bookmark"}]
                }
              },
              :servers                   => {},
              :key_pairs                 => {},
              :security_groups           => {
                '0' => {
                  "id"          => 0,
                  "tenant_id"   => Fog::Mock.random_hex(8),
                  "name"        => "default",
                  "description" => "default",
                  "rules"       => [
                    {"id"              => 0,
                     "parent_group_id" => 0,
                     "from_port"       => 68,
                     "to_port"         => 68,
                     "ip_protocol"     => "udp",
                     "ip_range"        => {"cidr" => "0.0.0.0/0"},
                     "group"           => {}},
                  ],
                },
              },
              :server_groups             => {},
              :server_security_group_map => {},
              :addresses                 => {},
              :quota                     => {
                'security_group_rules'        => 20,
                'security_groups'             => 10,
                'injected_file_content_bytes' => 10240,
                'injected_file_path_bytes'    => 256,
                'injected_files'              => 5,
                'metadata_items'              => 128,
                'floating_ips'                => 10,
                'instances'                   => 10,
                'key_pairs'                   => 10,
                'gigabytes'                   => 5000,
                'volumes'                     => 10,
                'cores'                       => 20,
                'ram'                         => 51200
              },
              :volumes                   => {},
              :snapshots                 => {},
              :os_interfaces             => [
                {
                  "fixed_ips" => [
                    {
                      "ip_address" => "192.168.1.3",
                      "subnet_id" => "f8a6e8f8-c2ec-497c-9f23-da9616de54ef"
                    }
                  ],
                  "mac_addr" => "fa:16:3e:4c:2c:30",
                  "net_id" => "3cb9bc59-5699-4588-a4b1-b87f96708bc6",
                  "port_id" => "ce531f90-199f-48c0-816c-13e38010b442",
                  "port_state" => "ACTIVE"
                }
              ]
            }  
          end
        end

        def self.reset
          @data = nil
        end

        include Fog::OpenStack::Core

        def initialize(options = {})
          @auth_token = Fog::Mock.random_base64(64)
          @auth_token_expiration = (Time.now.utc + 86400).iso8601

          initialize_identity options

          management_url = URI.parse(options[:openstack_auth_url])
          management_url.port = 8774
          management_url.path = '/v1.1/1'
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
      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Compute::OpenStack::NotFound
        end

        def initialize(options = {})
          @supported_versions = SUPPORTED_VERSIONS
          @supported_microversion = SUPPORTED_MICROVERSION
          @microversion_key = 'X-OpenStack-Nova-API-Version'

          initialize_identity options

          @openstack_identity_service_type = options[:openstack_identity_service_type] || 'identity'

          @openstack_service_type   = options[:openstack_service_type] || %w(nova compute)
          @openstack_service_name   = options[:openstack_service_name]

          @connection_options       = options[:connection_options] || {}

          authenticate

          unless @path =~ %r{/(v2|v2\.0|v2\.1)}
            raise Fog::OpenStack::Errors::ServiceUnavailable,
                  "OpenStack compute binding only supports version v2 and v2.1"
          end

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end
      end
    end
  end
end
