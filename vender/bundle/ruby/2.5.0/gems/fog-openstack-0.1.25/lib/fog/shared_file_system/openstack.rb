module Fog
  module SharedFileSystem
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /v2(\.0)*/
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
                 :openstack_identity_prefix, :openstack_shared_file_system_microversion

      model_path 'fog/shared_file_system/openstack/models'
      model       :network
      collection  :networks
      model       :share
      collection  :shares
      model       :snapshot
      collection  :snapshots
      model       :share_access_rule
      collection  :share_access_rules
      model       :share_export_location
      collection  :share_export_locations
      model       :availability_zone
      collection  :availability_zones

      request_path 'fog/shared_file_system/openstack/requests'
      # share networks
      request :list_share_networks
      request :list_share_networks_detail
      request :get_share_network
      request :create_share_network
      request :update_share_network
      request :delete_share_network

      # shares
      request :list_shares
      request :list_shares_detail
      request :get_share
      request :create_share
      request :update_share
      request :delete_share
      request :share_action
      request :grant_share_access
      request :revoke_share_access
      request :list_share_access_rules
      request :list_share_export_locations
      request :extend_share
      request :shrink_share

      # snapshots
      request :list_snapshots
      request :list_snapshots_detail
      request :get_snapshot
      request :create_snapshot
      request :update_snapshot
      request :delete_snapshot

      # quota + limits
      request :get_limits
      request :get_quota
      request :update_quota

      # availability zones
      request :list_availability_zones

      # rubocop:disable LineLength, Metrics/MethodLength, Metrics/ClassLength, Metrics/AbcSize
      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :shares                => [
                {
                  "id"    => "d94a8548-2079-4be0-b21c-0a887acd31ca",
                  "links" => [
                    {
                      "href" => "http://172.18.198.54:8786/v1/16e1ab15c35a457e9c2b2aa189f544e1/shares/d94a8548-2079-4be0-b21c-0a887acd31ca",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://172.18.198.54:8786/16e1ab15c35a457e9c2b2aa189f544e1/shares/d94a8548-2079-4be0-b21c-0a887acd31ca",
                      "rel"  => "bookmark"
                    }
                  ],
                  "name"  => "My_share"
                },
                {
                  "id"    => "406ea93b-32e9-4907-a117-148b3945749f",
                  "links" => [
                    {
                      "href" => "http://172.18.198.54:8786/v1/16e1ab15c35a457e9c2b2aa189f544e1/shares/406ea93b-32e9-4907-a117-148b3945749f",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://172.18.198.54:8786/16e1ab15c35a457e9c2b2aa189f544e1/shares/406ea93b-32e9-4907-a117-148b3945749f",
                      "rel"  => "bookmark"
                    }
                  ],
                  "name"  => "Share1"
                }
              ],
              :shares_detail         => [
                {
                  "links"                       => [
                    {
                      "href" => "http://172.18.198.54:8786/v2/16e1ab15c35a457e9c2b2aa189f544e1/shares/f45cc5b2-d1bb-4a3e-ba5b-5c4125613adc",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://172.18.198.54:8786/16e1ab15c35a457e9c2b2aa189f544e1/shares/f45cc5b2-d1bb-4a3e-ba5b-5c4125613adc",
                      "rel"  => "bookmark"
                    }
                  ],
                  "availability_zone"           => "nova",
                  "share_network_id"            => "f9b2e754-ac01-4466-86e1-5c569424754e",
                  "export_locations"            => [],
                  "share_server_id"             => "87d8943a-f5da-47a4-b2f2-ddfa6794aa82",
                  "snapshot_id"                 => '',
                  "id"                          => "f45cc5b2-d1bb-4a3e-ba5b-5c4125613adc",
                  "size"                        => 1,
                  "share_type"                  => "25747776-08e5-494f-ab40-a64b9d20d8f7",
                  "share_type_name"             => "default",
                  "export_location"             => '',
                  "consistency_group_id"        => "9397c191-8427-4661-a2e8-b23820dc01d4",
                  "project_id"                  => "16e1ab15c35a457e9c2b2aa189f544e1",
                  "metadata"                    => {},
                  "status"                      => "available",
                  "access_rules_status"         => "active",
                  "description"                 => "There is a share description.",
                  "host"                        => "manila2@generic1#GENERIC1",
                  "task_state"                  => '',
                  "is_public"                   => 'true',
                  "snapshot_support"            => 'true',
                  "name"                        => "my_share4",
                  "has_replicas"                => 'false',
                  "replication_type"            => '',
                  "created_at"                  => "2015-09-16T18:19:50.000000",
                  "share_proto"                 => "NFS",
                  "volume_type"                 => "default",
                  "source_cgsnapshot_member_id" => ''
                }
              ],
              :share_networks        => [
                {
                  "id"   => "32763294-e3d4-456a-998d-60047677c2fb",
                  "name" => "net_my1"
                },
                {
                  "id"   => "713df749-aac0-4a54-af52-10f6c991e80c",
                  "name" => "net_my"
                }
              ],
              :share_networks_detail => [
                {
                  "name"              => "net_my1",
                  "segmentation_id"   => '',
                  "created_at"        => "2015-09-04T14:57:13.000000",
                  "neutron_subnet_id" => "53482b62-2c84-4a53-b6ab-30d9d9800d06",
                  "updated_at"        => '',
                  "id"                => "32763294-e3d4-456a-998d-60047677c2fb",
                  "neutron_net_id"    => "998b42ee-2cee-4d36-8b95-67b5ca1f2109",
                  "ip_version"        => '',
                  "nova_net_id"       => '',
                  "cidr"              => '',
                  "project_id"        => "16e1ab15c35a457e9c2b2aa189f544e1",
                  "network_type"      => '',
                  "description"       => "descr"
                }
              ],
              :snapshots             => [
                {
                  "id"    => "086a1aa6-c425-4ecd-9612-391a3b1b9375",
                  "links" => [
                    {
                      "href" => "http://172.18.198.54:8786/v1/16e1ab15c35a457e9c2b2aa189f544e1/snapshots/086a1aa6-c425-4ecd-9612-391a3b1b9375",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://172.18.198.54:8786/16e1ab15c35a457e9c2b2aa189f544e1/snapshots/086a1aa6-c425-4ecd-9612-391a3b1b9375",
                      "rel"  => "bookmark"
                    }
                  ],
                  "name"  => "snapshot_My_share"
                }
              ],
              :availability_zones => [
                  {
                      "name"        => "nova",
                      "created_at"  => "2015-09-18T09:50:55.000000",
                      "updated_at"  => nil,
                      "id"          => "388c983d-258e-4a0e-b1ba-10da37d766db"
                  }
              ],
              :snapshots_detail      => [
                {
                  "status"      => "available",
                  "share_id"    => "d94a8548-2079-4be0-b21c-0a887acd31ca",
                  "name"        => "snapshot_My_share",
                  "links"       => [
                    {
                      "href" => "http://172.18.198.54:8786/v1/16e1ab15c35a457e9c2b2aa189f544e1/snapshots/086a1aa6-c425-4ecd-9612-391a3b1b9375",
                      "rel"  => "self"
                    },
                    {
                      "href" => "http://172.18.198.54:8786/16e1ab15c35a457e9c2b2aa189f544e1/snapshots/086a1aa6-c425-4ecd-9612-391a3b1b9375",
                      "rel"  => "bookmark"
                    }
                  ],
                  "created_at"  => "2015-09-07T11:55:09.000000",
                  "description" => "Here is a snapshot of share My_share",
                  "share_proto" => "NFS",
                  "share_size"  => 1,
                  "id"          => "086a1aa6-c425-4ecd-9612-391a3b1b9375",
                  "size"        => 1
                }
              ],
              :export_locations      => [
                {
                  "path"              => "10.254.0.3:/shares/share-e1c2d35e-fe67-4028-ad7a-45f668732b1d",
                  "share_instance_id" => "e1c2d35e-fe67-4028-ad7a-45f668732b1d",
                  "is_admin_only"     => false,
                  "id"                => "b6bd76ce-12a2-42a9-a30a-8a43b503867d",
                  "preferred"         => false
                },
                {
                  "path"              => "10.0.0.3:/shares/share-e1c2d35e-fe67-4028-ad7a-45f668732b1d",
                  "share_instance_id" => "e1c2d35e-fe67-4028-ad7a-45f668732b1d",
                  "is_admin_only"     => true,
                  "id"                => "6921e862-88bc-49a5-a2df-efeed9acd583",
                  "preferred"         => false
                }
              ],

              :access_rules          => [
                {
                  "share_id"     => "406ea93b-32e9-4907-a117-148b3945749f",
                  "created_at"   => "2015-09-07T09:14:48.000000",
                  "updated_at"   => '',
                  "access_type"  => "ip",
                  "access_to"    => "0.0.0.0/0",
                  "access_level" => "rw",
                  "access_key"   => '',
                  "id"           => "a25b2df3-90bd-4add-afa6-5f0dbbd50452"
                }
              ],
              :quota                 => {
                "gigabytes"          => 1000,
                "shares"             => 50,
                "snapshot_gigabytes" => 1000,
                "snapshots"          => 50,
                "share_networks"     => 10,
                "id"                 => "16e1ab15c35a457e9c2b2aa189f544e1"
              }
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
          management_url.port = 8786
          management_url.path = '/v2'
          @openstack_management_url = management_url.to_s

          @data ||= {:users => {}}
          unless @data[:users].detect { |u| u['name'] == options[:openstack_username] }
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
      # rubocop:enable LineLength, Metrics/MethodLength, Metrics/ClassLength, Metrics/AbcSize

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::SharedFileSystem::OpenStack::NotFound
        end

        def initialize(options = {})
          @supported_versions     = SUPPORTED_VERSIONS
          @supported_microversion = SUPPORTED_MICROVERSION
          @fixed_microversion     = options[:openstack_shared_file_system_microversion]
          @microversion_key       = 'X-Openstack-Manila-Api-Version'.freeze

          initialize_identity options

          @openstack_service_type  = options[:openstack_service_type] || ['sharev2']
          @openstack_service_name  = options[:openstack_service_name]
          @connection_options      = options[:connection_options] || {}

          authenticate
          set_api_path
          set_microversion

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def set_api_path
          unless @path.match(@supported_versions)
            @path = Fog::OpenStack.get_supported_version_path(@supported_versions,
                                                              @openstack_management_uri,
                                                              @auth_token,
                                                              @connection_options)
          end
        end

        def action_prefix
          microversion_newer_than?('2.6') ? '' : 'os-'
        end
      end
    end
  end
end
