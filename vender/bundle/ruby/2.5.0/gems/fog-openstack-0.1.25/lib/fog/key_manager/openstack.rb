module Fog
  module KeyManager
    class OpenStack < Fog::Service
      SUPPORTED_VERSIONS = /v1(\.0)*/

      requires :openstack_auth_url
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


      ## MODELS
      #
      model_path 'fog/key_manager/openstack/models'
      model       :secret
      collection  :secrets
      model       :container
      collection  :containers
      model       :acl

      ## REQUESTS

      # secrets
      request_path 'fog/key_manager/openstack/requests'
      request :create_secret
      request :list_secrets
      request :get_secret
      request :get_secret_payload
      request :get_secret_metadata
      request :delete_secret

      # containers
      request :create_container
      request :get_container
      request :list_containers
      request :delete_container

      #ACL
      request :get_secret_acl
      request :update_secret_acl
      request :replace_secret_acl
      request :delete_secret_acl

      request :get_container_acl
      request :update_container_acl
      request :replace_container_acl
      request :delete_container_acl

      class Mock
        def initialize(options = {})
          @openstack_username = options[:openstack_username]
          @openstack_tenant   = options[:openstack_tenant]
          @openstack_auth_uri = URI.parse(options[:openstack_auth_url])

          @auth_token = Fog::Mock.random_base64(64)
          @auth_token_expiration = (Time.now.utc + 86400).iso8601

          management_url = URI.parse(options[:openstack_auth_url])
          management_url.port = 9311
          management_url.path = '/v1'
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
          Fog::KeyManager::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type           = options[:openstack_service_type] || ['key-manager']
          @openstack_service_name           = options[:openstack_service_name]
          @connection_options               = options[:connection_options] || {}

          authenticate
          set_api_path

          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def set_api_path
          @path.sub!(%r{/$}, '')
          unless @path.match(SUPPORTED_VERSIONS)
            @path = supported_version(SUPPORTED_VERSIONS, @openstack_management_uri, @auth_token, @connection_options)
          end
        end

        def supported_version(supported_versions, uri, auth_token, connection_options = {})
          connection = Fog::Core::Connection.new("#{uri.scheme}://#{uri.host}:#{uri.port}", false, connection_options)
          response = connection.request({ :expects => [200, 204, 300],
                                          :headers => {'Content-Type' => 'application/json',
                                                       'Accept' => 'application/json',
                                                       'X-Auth-Token' => auth_token},
                                          :method => 'GET'
                                        })

          body = Fog::JSON.decode(response.body)
          version = nil

          versions =  body.fetch('versions',{}).fetch('values',[])
          versions.each do |v|
            if v.fetch('id', "").match(supported_versions) &&
              ['current', 'supported', 'stable'].include?(v.fetch('status','').downcase)
              version = v['id']
            end
          end

          if !version  || version.empty?
            raise Fog::OpenStack::Errors::ServiceUnavailable.new(
                    "OpenStack service only supports API versions #{supported_versions.inspect}")
          end

          version
        end

      end
    end
  end
end
