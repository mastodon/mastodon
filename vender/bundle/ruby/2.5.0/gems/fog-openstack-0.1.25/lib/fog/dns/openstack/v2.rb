require 'fog/dns/openstack'

module Fog
  module DNS
    class OpenStack
      class V2 < Fog::Service
        SUPPORTED_VERSIONS = /v2/

        requires   :openstack_auth_url
        recognizes :openstack_auth_token, :openstack_management_url,
                   :persistent, :openstack_service_type, :openstack_service_name,
                   :openstack_tenant, :openstack_tenant_id, :openstack_userid,
                   :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                   :current_user, :current_tenant, :openstack_region,
                   :openstack_endpoint_type, :openstack_auth_omit_default_port,
                   :openstack_project_name, :openstack_project_id,
                   :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                   :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                   :openstack_identity_prefix, :openstack_temp_url_key, :openstack_cache_ttl

        model_path 'fog/dns/openstack/v2/models'
        model       :zone
        collection  :zones
        model       :recordset
        collection  :recordsets
        model       :pool
        collection  :pools
        model       :zone_transfer_request
        collection  :zone_transfer_requests
        model       :zone_transfer_accept
        collection  :zone_transfer_accepts

        request_path 'fog/dns/openstack/v2/requests'

        request :list_zones
        request :get_zone
        request :create_zone
        request :update_zone
        request :delete_zone

        request :list_recordsets
        request :get_recordset
        request :create_recordset
        request :update_recordset
        request :delete_recordset

        request :list_pools
        request :get_pool

        request :get_quota
        request :update_quota

        request :create_zone_transfer_request
        request :get_zone_transfer_request
        request :list_zone_transfer_requests
        request :update_zone_transfer_request
        request :delete_zone_transfer_request

        request :create_zone_transfer_accept
        request :get_zone_transfer_accept
        request :list_zone_transfer_accepts


        def self.setup_headers(options)
          # user needs to have admin privileges to ask for all projects
          all_projects = options.delete(:all_projects) || false

          # user needs to have admin privileges to impersonate another project
          # don't ask for all and one project at the same time
          project_id = options.delete(:project_id) unless all_projects

          headers = {'X-Auth-All-Projects' => all_projects}
          headers['X-Auth-Sudo-Project-Id'] = project_id unless project_id.nil?

          [headers, options]
        end

        class Mock
          def self.data
            @data ||= Hash.new do |hash, key|
              hash[key] = {
                :zones      => [{
                  "id"             => "a86dba58-0043-4cc6-a1bb-69d5e86f3ca3",
                  "pool_id"        => "572ba08c-d929-4c70-8e42-03824bb24ca2",
                  "project_id"     => "4335d1f0-f793-11e2-b778-0800200c9a66",
                  "name"           => "example.org.",
                  "email"          => "joe@example.org",
                  "ttl"            => 7200,
                  "serial"         => 1_404_757_531,
                  "status"         => "ACTIVE",
                  "action"         => "NONE",
                  "description"    => "This is an example zone.",
                  "masters"        => [],
                  "type"           => "PRIMARY",
                  "transferred_at" => '',
                  "version"        => 1,
                  "created_at"     => "2014-07-07T18:25:31.275934",
                  "updated_at"     => '',
                  "links"          => {
                    "self" => "https://127.0.0.1:9001/v2/zones/a86dba58-0043-4cc6-a1bb-69d5e86f3ca3"
                  }
                }],
                :pools      => {
                  "metadata" => {
                    "total_count" => 2
                  },
                  "links"    => {
                    "self" => "http://127.0.0.1:9001/v2/pools"
                  },
                  "pools"    => [
                    {
                      "description" => '',
                      "id"          => "794ccc2c-d751-44fe-b57f-8894c9f5c842",
                      "project_id"  => '',
                      "created_at"  => "2015-02-18T22:18:58.000000",
                      "attributes"  => '',
                      "ns_records"  => [
                        {
                          "hostname" => "ns1.example.org.",
                          "priority" => 1
                        }
                      ],
                      "links"       => {
                        "self" => "http://127.0.0.1:9001/v2/pools/794ccc2c-d751-44fe-b57f-8894c9f5c842"
                      },
                      "name"        => "default",
                      "updated_at"  => "2015-02-19T15:59:44.000000"
                    },
                    {
                      "description" => '',
                      "id"          => "d1716333-8c16-490f-85ee-29af36907605",
                      "project_id"  => "noauth-project",
                      "created_at"  => "2015-02-23T21:56:33.000000",
                      "attributes"  => '',
                      "ns_records"  => [
                        {
                          "hostname" => "ns2.example.org.",
                          "priority" => 1
                        }
                      ],
                      "links"       => {
                        "self" => "http://127.0.0.1:9001/v2/pools/d1716333-8c16-490f-85ee-29af36907605"
                      },
                      "name"        => "example_pool",
                      "updated_at"  => ''
                    }
                  ]
                },
                :quota      => {
                  "api_export_size"   => 1000,
                  "recordset_records" => 20,
                  "zone_records"      => 500,
                  "zone_recordsets"   => 500,
                  "zones"             => 100
                },
                :recordsets => {
                  "recordsets" => [{
                    "description" => "This is an example record set.",
                    "links"       => {
                      "self" => "https://127.0.0.1:9001/v2/zones/2150b1bf-dee2-4221-9d85-11f7886fb15f/recordsets/f7b10e9b-0cae-4a91-b162-562bc6096648"
                    },
                    "updated_at"  => '',
                    "records"     => [
                      "10.1.0.2"
                    ],
                    "ttl"         => 3600,
                    "id"          => "f7b10e9b-0cae-4a91-b162-562bc6096648",
                    "name"        => "example.org.",
                    "project_id"  => "4335d1f0-f793-11e2-b778-0800200c9a66",
                    "zone_id"     => "2150b1bf-dee2-4221-9d85-11f7886fb15f",
                    "zone_name"   => "example.com.",
                    "created_at"  => "2014-10-24T19:59:44.000000",
                    "version"     => 1,
                    "type"        => "A",
                    "status"      => "ACTIVE",
                    "action"      => "NONE"
                  }],
                  "links"      => {
                    "self" => "http://127.0.0.1:9001/v2/recordsets?limit=1",
                    "next" => "http://127.0.0.1:9001/v2/recordsets?limit=1&marker=45fd892d-7a67-4f65-9df0-87273f228d6c"
                  },
                  "metadata"   => {
                    "total_count" => 2
                  }
                },
                :zone_transfer_requests => {
                  "transfer_requests" => [
                    {
                      "created_at" => "2014-07-17T20:34:40.882579",
                      "description" => "This was created by the requesting project",
                      "id" => "f2ad17b5-807a-423f-a991-e06236c247be",
                      "key" => "9Z2R50Y0",
                      "project_id" => "1",
                      "status" => "ACTIVE",
                      "target_project_id" => "123456",
                      "updated_at" => nil,
                      "zone_id" => "6b78734a-aef1-45cd-9708-8eb3c2d26ff8",
                      "zone_name" => "qa.dev.example.com.",
                      "links" => {
                        "self" => "http://127.0.0.1:9001/v2/zones/tasks/transfer_requests/f2ad17b5-807a-423f-a991-e06236c247be"
                      }
                    },
                    {
                      "description" => "This is scoped to the requesting project",
                      "id" => "efd2d720-b0c4-43d4-99f7-d9b53e08860d",
                      "zone_id" => "2c4d5e37-f823-4bee-9859-031cb44f80e7",
                      "zone_name" => "subdomain.example.com.",
                      "status" => "ACTIVE",
                      "links" => {
                        "self" => "http://127.0.0.1:9001/v2/zones/tasks/transfer_requests/efd2d720-b0c4-43d4-99f7-d9b53e08860d"
                      }
                    }
                  ],
                  "links" => {
                    "self" => "http://127.0.0.1:9001/v2/zones/tasks/transfer_requests"
                  }
                },
                :zone_transfer_accepts => {
                  "metadata" => {
                     "total_count" => 2
                   },
                   "links" => {
                     "self" => "http://127.0.0.1:9001/v2/zones/tasks/transfer_accepts"
                   },
                   "transfer_accepts" => [
                     {
                       "status" => "COMPLETE",
                       "zone_id" => "8db93d1a-59e3-4143-a393-5821abea0a46",
                       "links" => {
                           "self" => "http://127.0.0.1:9001/v2/zones/tasks/transfer_accepts/afb4222b-18b3-44b3-9f54-e0dfdba1be44",
                           "zone" => "http://127.0.0.1:9001/v2/zones/8db93d1a-59e3-4143-a393-5821abea0a46"
                       },
                       "created_at" => "2016-06-01 05:35:35",
                       "updated_at" => "2016-06-01 05:35:35",
                       "key" => nil,
                       "project_id" => "85604ecfb5334b50bd40ca53fc1d710f",
                       "id" => "afb4222b-18b3-44b3-9f54-e0dfdba1be44",
                       "zone_transfer_request_id" => "d223f7ef-77a6-459e-abd3-b4dbc97338e7"
                     },
                     {
                       "status" => "COMPLETE",
                       "zone_id" => "925bfc45-8901-4aca-aa12-18afaf0879e2",
                       "links" => {
                           "self" => "http://127.0.0.1:9001/v2/zones/tasks/transfer_accepts/ecbc7091-c498-4ec4-9893-68b06297fe50",
                           "zone" => "http://127.0.0.1:9001/v2/zones/925bfc45-8901-4aca-aa12-18afaf0879e2"
                       },
                       "created_at" => "2016-06-01 10:06:36",
                       "updated_at" => "2016-06-01 10:06:37",
                       "key" => nil,
                       "project_id" => "85604ecfb5334b50bd40ca53fc1d710f",
                       "id" => "ecbc7091-c498-4ec4-9893-68b06297fe50",
                       "zone_transfer_request_id" => "94cf9bd3-4137-430b-bf75-4e690430258c"
                     }
                   ]
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
            management_url.port = 9001
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

        class Real
          include Fog::OpenStack::Core

          def self.not_found_class
            Fog::DNS::OpenStack::NotFound
          end

          def initialize(options = {})
            initialize_identity options

            @openstack_service_type           = options[:openstack_service_type] || ['dns']
            @openstack_service_name           = options[:openstack_service_name]

            @connection_options               = options[:connection_options] || {}

            authenticate
            set_api_path
            @persistent = options[:persistent] || false
            @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}/", @persistent, @connection_options)
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
end
