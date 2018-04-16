

module Fog
  module Network
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /v2(\.0)*/

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
      model_path 'fog/network/openstack/models'
      model       :extension
      collection  :extensions
      model       :network
      collection  :networks
      model       :port
      collection  :ports
      model       :subnet
      collection  :subnets
      model       :subnet_pool
      collection  :subnet_pools
      model       :floating_ip
      collection  :floating_ips
      model       :router
      collection  :routers
      model       :lb_pool
      collection  :lb_pools
      model       :lb_member
      collection  :lb_members
      model       :lb_health_monitor
      collection  :lb_health_monitors
      model       :lb_vip
      collection  :lb_vips
      model       :vpn_service
      collection  :vpn_services
      model       :ike_policy
      collection  :ike_policies
      model       :ipsec_policy
      collection  :ipsec_policies
      model       :ipsec_site_connection
      collection  :ipsec_site_connections
      model       :rbac_policy
      collection  :rbac_policies
      model       :security_group
      collection  :security_groups
      model       :security_group_rule
      collection  :security_group_rules
      model       :network_ip_availability
      collection  :network_ip_availabilities

      ## REQUESTS
      #
      request_path 'fog/network/openstack/requests'

      # Neutron Extensions
      request :list_extensions
      request :get_extension

      # IP Availability
      request :get_network_ip_availability
      request :list_network_ip_availabilities

      # Network CRUD
      request :list_networks
      request :create_network
      request :delete_network
      request :get_network
      request :update_network

      # Port CRUD
      request :list_ports
      request :create_port
      request :delete_port
      request :get_port
      request :update_port

      # Subnet CRUD
      request :list_subnets
      request :create_subnet
      request :delete_subnet
      request :get_subnet
      request :update_subnet

      # Subnet Pools CRUD
      request :list_subnet_pools
      request :create_subnet_pool
      request :delete_subnet_pool
      request :get_subnet_pool
      request :update_subnet_pool

      # FloatingIp CRUD
      request :list_floating_ips
      request :create_floating_ip
      request :delete_floating_ip
      request :get_floating_ip
      request :associate_floating_ip
      request :disassociate_floating_ip

      # Router CRUD
      request :list_routers
      request :create_router
      request :delete_router
      request :get_router
      request :update_router
      request :add_router_interface
      request :remove_router_interface

      #
      # LBaaS V1
      #

      # LBaaS Pool CRUD
      request :list_lb_pools
      request :create_lb_pool
      request :delete_lb_pool
      request :get_lb_pool
      request :get_lb_pool_stats
      request :update_lb_pool

      # LBaaS Member CRUD
      request :list_lb_members
      request :create_lb_member
      request :delete_lb_member
      request :get_lb_member
      request :update_lb_member

      # LBaaS Health Monitor CRUD
      request :list_lb_health_monitors
      request :create_lb_health_monitor
      request :delete_lb_health_monitor
      request :get_lb_health_monitor
      request :update_lb_health_monitor
      request :associate_lb_health_monitor
      request :disassociate_lb_health_monitor

      # LBaaS VIP CRUD
      request :list_lb_vips
      request :create_lb_vip
      request :delete_lb_vip
      request :get_lb_vip
      request :update_lb_vip

      #
      # LBaaS V2
      #

      # LBaaS V2 Loadbanacer
      request :list_lbaas_loadbalancers
      request :create_lbaas_loadbalancer
      request :delete_lbaas_loadbalancer
      request :get_lbaas_loadbalancer
      request :update_lbaas_loadbalancer

      # LBaaS V2 Listener
      request :list_lbaas_listeners
      request :create_lbaas_listener
      request :delete_lbaas_listener
      request :get_lbaas_listener
      request :update_lbaas_listener

      # LBaaS V2 Pool
      request :list_lbaas_pools
      request :create_lbaas_pool
      request :delete_lbaas_pool
      request :get_lbaas_pool
      request :update_lbaas_pool

      # LBaaS V2 Pool_Member
      request :list_lbaas_pool_members
      request :create_lbaas_pool_member
      request :delete_lbaas_pool_member
      request :get_lbaas_pool_member
      request :update_lbaas_pool_member

      # LBaaS V2 Healthmonitor
      request :list_lbaas_healthmonitors
      request :create_lbaas_healthmonitor
      request :delete_lbaas_healthmonitor
      request :get_lbaas_healthmonitor
      request :update_lbaas_healthmonitor

      # LBaaS V2 L7Policy
      request :list_lbaas_l7policies
      request :create_lbaas_l7policy
      request :delete_lbaas_l7policy
      request :get_lbaas_l7policy
      request :update_lbaas_l7policy

      # LBaaS V2 L7Rule
      request :list_lbaas_l7rules
      request :create_lbaas_l7rule
      request :delete_lbaas_l7rule
      request :get_lbaas_l7rule
      request :update_lbaas_l7rule

      # VPNaaS VPN Service CRUD
      request :list_vpn_services
      request :create_vpn_service
      request :delete_vpn_service
      request :get_vpn_service
      request :update_vpn_service

      # VPNaaS VPN IKE Policy CRUD
      request :list_ike_policies
      request :create_ike_policy
      request :delete_ike_policy
      request :get_ike_policy
      request :update_ike_policy

      # VPNaaS VPN IPSec Policy CRUD
      request :list_ipsec_policies
      request :create_ipsec_policy
      request :delete_ipsec_policy
      request :get_ipsec_policy
      request :update_ipsec_policy

      # VPNaaS VPN IPSec Site Connection CRUD
      request :list_ipsec_site_connections
      request :create_ipsec_site_connection
      request :delete_ipsec_site_connection
      request :get_ipsec_site_connection
      request :update_ipsec_site_connection

      # RBAC Policy CRUD
      request :list_rbac_policies
      request :create_rbac_policy
      request :delete_rbac_policy
      request :get_rbac_policy
      request :update_rbac_policy

      # Security Group
      request :create_security_group
      request :delete_security_group
      request :get_security_group
      request :list_security_groups
      request :update_security_group

      # Security Group Rules
      request :create_security_group_rule
      request :delete_security_group_rule
      request :get_security_group_rule
      request :list_security_group_rules

      # Tenant
      request :set_tenant

      # Quota
      request :get_quotas
      request :get_quota
      request :update_quota
      request :delete_quota

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            qos_policy_id = Fog::UUID.uuid
            network_id   = Fog::UUID.uuid
            extension_id = Fog::UUID.uuid
            subnet_id    = Fog::UUID.uuid
            tenant_id    = Fog::Mock.random_hex(8)

            hash[key] = {
              :extensions             => {
                extension_id => {
                  'id'          => extension_id,
                  'alias'       => 'dvr',
                  'description' => 'Enables configuration of Distributed Virtual Routers.',
                  'links'       => [],
                  'name'        => 'Distributed Virtual Router'
                }
              },
              :networks               => {
                network_id                => {
                  'id'                    => network_id,
                  'name'                  => 'Public',
                  'subnets'               => [subnet_id],
                  'shared'                => true,
                  'status'                => 'ACTIVE',
                  'tenant_id'             => tenant_id,
                  'provider:network:type' => 'vlan',
                  'router:external'       => false,
                  'admin_state_up'        => true,
                  'qos_policy_id'         => qos_policy_id,
                  'port_security_enabled' => true
                },
                'e624a36d-762b-481f-9b50-4154ceb78bbb' => {
                  'id'                    => 'e624a36d-762b-481f-9b50-4154ceb78bbb',
                  'name'                  => 'network_1',
                  'subnets'               => ['2e4ec6a4-0150-47f5-8523-e899ac03026e'],
                  'shared'                => false,
                  'status'                => 'ACTIVE',
                  'tenant_id'             => 'f8b26a6032bc47718a7702233ac708b9',
                  'provider:network:type' => 'vlan',
                  'router:external'       => false,
                  'admin_state_up'        => true,
                  'qos_policy_id'         => qos_policy_id,
                  'port_security_enabled' => true
                }
              },
              :ports                  => {},
              :subnets                => {
                subnet_id => {
                  'id'               => subnet_id,
                  'name'             => "Public",
                  'network_id'       => network_id,
                  'cidr'             => "192.168.0.0/22",
                  'ip_version'       => 4,
                  'gateway_ip'       => Fog::Mock.random_ip,
                  'allocation_pools' => [],
                  'dns_nameservers'  => [Fog::Mock.random_ip, Fog::Mock.random_ip],
                  'host_routes'      => [Fog::Mock.random_ip],
                  'enable_dhcp'      => true,
                  'tenant_id'        => tenant_id,
                }
              },
              :subnet_pools           => {},
              :floating_ips           => {},
              :routers                => {},
              :lb_pools               => {},
              :lb_members             => {},
              :lb_health_monitors     => {},
              :lb_vips                => {},
              :lbaas_loadbalancers    => {},
              :lbaas_listeners        => {},
              :lbaas_pools            => {},
              :lbaas_pool_members     => {},
              :lbaas_health_monitorss => {},
              :lbaas_l7policies       => {},
              :lbaas_l7rules          => {},
              :vpn_services           => {},
              :ike_policies           => {},
              :ipsec_policies         => {},
              :ipsec_site_connections => {},
              :rbac_policies          => {},
              :quota                  => {
                "subnet"     => 10,
                "router"     => 10,
                "port"       => 50,
                "network"    => 10,
                "floatingip" => 50
              },
              :quotas                 => [
                {
                  "subnet"     => 10,
                  "network"    => 10,
                  "floatingip" => 50,
                  "tenant_id"  => tenant_id,
                  "router"     => 10,
                  "port"       => 30
                }
              ],
              :security_groups            => {},
              :security_group_rules       => {},
              :network_ip_availabilities  => [
                {
                  "network_id"              => "4cf895c9-c3d1-489e-b02e-59b5c8976809",
                  "network_name"            => "public",
                  "subnet_ip_availability"  => [
                    {
                      "cidr"          => "2001:db8::/64",
                      "ip_version"    => 6,
                      "subnet_id"     => "ca3f46c4-c6ff-4272-9be4-0466f84c6077",
                      "subnet_name"   => "ipv6-public-subnet",
                      "total_ips"     => 18446744073709552000,
                      "used_ips"      => 1
                    },
                    {
                      "cidr"          => "172.24.4.0/24",
                      "ip_version"    => 4,
                      "subnet_id"     => "cc02efc1-9d47-46bd-bab6-760919c836b5",
                      "subnet_name"   => "public-subnet",
                      "total_ips"     => 253,
                      "used_ips"      => 1
                    }
                  ],
                  "project_id"  => "1a02cc95f1734fcc9d3c753818f03002",
                  "tenant_id"   => "1a02cc95f1734fcc9d3c753818f03002",
                  "total_ips"   => 253,
                  "used_ips"    => 2
                },
                {
                  "network_id"              => "6801d9c8-20e6-4b27-945d-62499f00002e",
                  "network_name"            => "private",
                  "subnet_ip_availability"  => [
                    {
                      "cidr"        => "10.0.0.0/24",
                      "ip_version"  => 4,
                      "subnet_id"   => "44e70d00-80a2-4fb1-ab59-6190595ceb61",
                      "subnet_name" => "private-subnet",
                      "total_ips"   => 253,
                      "used_ips"    => 2
                    },
                    {
                      "ip_version"  => 6,
                      "cidr"        => "fdbf:ac66:9be8::/64",
                      "subnet_id"   => "a90623df-00e1-4902-a675-40674385d74c",
                      "subnet_name" => "ipv6-private-subnet",
                      "total_ips"   => 18446744073709552000,
                      "used_ips"    => 2
                    }
                  ],
                  "project_id"  => "d56d3b8dd6894a508cf41b96b522328c",
                  "tenant_id"   => "d56d3b8dd6894a508cf41b96b522328c",
                  "total_ips"   => 18446744073709552000,
                  "used_ips"    => 4
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
        end

        def data
          self.class.data["#{@openstack_username}-#{@openstack_tenant}"]
        end

        def reset_data
          self.class.data.delete("#{@openstack_username}-#{@openstack_tenant}")
        end
      end

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Network::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type = options[:openstack_service_type] || ['network']
          @openstack_service_name = options[:openstack_service_name]

          @connection_options     = options[:connection_options] || {}

          authenticate
          set_api_path

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def set_api_path
          @path.sub!(%r{/$}, '')
          unless @path.match(SUPPORTED_VERSIONS)
            @path = Fog::OpenStack.get_supported_version_path(SUPPORTED_VERSIONS,
                                                              @openstack_management_uri,
                                                              @auth_token,
                                                              @connection_options)
          end
        end
      end
    end
  end
end
