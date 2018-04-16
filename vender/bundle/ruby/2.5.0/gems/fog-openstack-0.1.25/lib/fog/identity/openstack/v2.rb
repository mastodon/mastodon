require 'fog/identity/openstack'

module Fog
  module Identity
    class OpenStack
      class V2 < Fog::Service
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
                   :openstack_identity_prefix, :openstack_endpoint_path_matches

        model_path 'fog/identity/openstack/v2/models'
        model :tenant
        collection :tenants
        model :user
        collection :users
        model :role
        collection :roles
        model :ec2_credential
        collection :ec2_credentials

        request_path 'fog/identity/openstack/v2/requests'

        request :check_token
        request :validate_token

        request :list_tenants
        request :create_tenant
        request :get_tenant
        request :get_tenants_by_id
        request :get_tenants_by_name
        request :update_tenant
        request :delete_tenant

        request :list_users
        request :create_user
        request :update_user
        request :delete_user
        request :get_user_by_id
        request :get_user_by_name
        request :add_user_to_tenant
        request :remove_user_from_tenant

        request :list_endpoints_for_token
        request :list_roles_for_user_on_tenant
        request :list_user_global_roles

        request :create_role
        request :delete_role
        request :delete_user_role
        request :create_user_role
        request :get_role
        request :list_roles

        request :set_tenant

        request :create_ec2_credential
        request :delete_ec2_credential
        request :get_ec2_credential
        request :list_ec2_credentials

        class Mock
          attr_reader :auth_token
          attr_reader :auth_token_expiration
          attr_reader :current_user
          attr_reader :current_tenant
          attr_reader :unscoped_token

          def self.data
            @users ||= {}
            @roles ||= {}
            @tenants ||= {}
            @ec2_credentials ||= Hash.new { |hash, key| hash[key] = {} }
            @user_tenant_membership ||= {}

            @data ||= Hash.new do |hash, key|
              hash[key] = {
                :users                  => @users,
                :roles                  => @roles,
                :tenants                => @tenants,
                :ec2_credentials        => @ec2_credentials,
                :user_tenant_membership => @user_tenant_membership
              }
            end
          end

          def self.reset!
            @data = nil
            @users = nil
            @roles = nil
            @tenants = nil
            @ec2_credentials = nil
          end

          def initialize(options = {})
            @openstack_username = options[:openstack_username] || 'admin'
            @openstack_tenant = options[:openstack_tenant] || 'admin'
            @openstack_auth_uri = URI.parse(options[:openstack_auth_url])
            @openstack_management_url = @openstack_auth_uri.to_s

            @auth_token = Fog::Mock.random_base64(64)
            @auth_token_expiration = (Time.now.utc + 86400).iso8601

            @admin_tenant = data[:tenants].values.find do |u|
              u['name'] == 'admin'
            end

            if @openstack_tenant
              @current_tenant = data[:tenants].values.find do |u|
                u['name'] == @openstack_tenant
              end

              if @current_tenant
                @current_tenant_id = @current_tenant['id']
              else
                @current_tenant_id = Fog::Mock.random_hex(32)
                @current_tenant = data[:tenants][@current_tenant_id] = {
                  'id'   => @current_tenant_id,
                  'name' => @openstack_tenant
                }
              end
            else
              @current_tenant = @admin_tenant
            end

            @current_user = data[:users].values.find do |u|
              u['name'] == @openstack_username
            end
            @current_tenant_id = Fog::Mock.random_hex(32)

            if @current_user
              @current_user_id = @current_user['id']
            else
              @current_user_id = Fog::Mock.random_hex(32)
              @current_user = data[:users][@current_user_id] = {
                'id'       => @current_user_id,
                'name'     => @openstack_username,
                'email'    => "#{@openstack_username}@mock.com",
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
            {:provider                  => 'openstack',
             :openstack_auth_url        => @openstack_auth_uri.to_s,
             :openstack_auth_token      => @auth_token,
             :openstack_management_url  => @openstack_management_url,
             :openstack_current_user_id => @openstack_current_user_id,
             :current_user              => @current_user,
             :current_tenant            => @current_tenant}
          end
        end

        class Real < Fog::Identity::OpenStack::Real
          private

          def default_service_type(_)
            DEFAULT_SERVICE_TYPE
          end
        end
      end
    end
  end
end
