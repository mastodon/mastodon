

module Fog
  module Storage
    class OpenStack < Fog::Service
      requires   :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id, :openstack_userid,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_auth_omit_default_port,
                 :openstack_project_name, :openstack_project_id, :openstack_cache_ttl,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                 :openstack_identity_prefix, :openstack_temp_url_key

      model_path 'fog/storage/openstack/models'
      model       :directory
      collection  :directories
      model       :file
      collection  :files

      request_path 'fog/storage/openstack/requests'
      request :copy_object
      request :delete_container
      request :delete_object
      request :delete_multiple_objects
      request :delete_static_large_object
      request :get_container
      request :get_containers
      request :get_object
      request :get_object_http_url
      request :get_object_https_url
      request :head_container
      request :head_containers
      request :head_object
      request :put_container
      request :put_object
      request :post_object
      request :put_object_manifest
      request :put_dynamic_obj_manifest
      request :put_static_obj_manifest
      request :post_set_meta_temp_url_key
      request :public_url

      module Utils
        def require_mime_types
          # Use mime/types/columnar if available, for reduced memory usage
          require 'mime/types/columnar'
          rescue LoadError
            begin
              require 'mime/types'
            rescue LoadError
              Fog::Logger.warning("'mime-types' missing, please install and try again.")
              exit(1)
            end
          end
      end

      class Mock
        include Utils
        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options = {})
          require_mime_types
          @openstack_api_key = options[:openstack_api_key]
          @openstack_username = options[:openstack_username]
          @openstack_management_url = options[:openstack_management_url] || 'http://example:8774/v2/AUTH_1234'

          @openstack_management_uri = URI.parse(@openstack_management_url)

          @host   = @openstack_management_uri.host
          @path   = @openstack_management_uri.path
          @path.sub!(%r{/$}, '')
          @port   = @openstack_management_uri.port
          @scheme = @openstack_management_uri.scheme
        end

        def data
          self.class.data[@openstack_username]
        end

        def reset_data
          self.class.data.delete(@openstack_username)
        end

        def change_account(account)
          @original_path ||= @path
          version_string = @original_path.split('/')[1]
          @path = "/#{version_string}/#{account}"
        end

        def reset_account_name
          @path = @original_path
        end
      end

      class Real
        include Utils
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Storage::OpenStack::NotFound
        end

        def initialize(options = {})
          require_mime_types
          initialize_identity options

          @openstack_service_type           = options[:openstack_service_type] || ['object-store']
          @openstack_service_name           = options[:openstack_service_name]

          @connection_options               = options[:connection_options] || {}

          authenticate
          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        # Change the current account while re-using the auth token.
        #
        # This is usefull when you have an admin role and you're able
        # to HEAD other user accounts, set quotas, list files, etc.
        #
        # For example:
        #
        #     # List current user account details
        #     service = Fog::Storage[:openstack]
        #     service.request :method => 'HEAD'
        #
        # Would return something like:
        #
        #     Account:                      AUTH_1234
        #     Date:                         Tue, 05 Mar 2013 16:50:52 GMT
        #     X-Account-Bytes-Used:         0 (0.00 Bytes)
        #     X-Account-Container-Count:    0
        #     X-Account-Object-Count:       0
        #
        # Now let's change the account
        #
        #     service.change_account('AUTH_3333')
        #     service.request :method => 'HEAD'
        #
        # Would return something like:
        #
        #     Account:                      AUTH_3333
        #     Date:                         Tue, 05 Mar 2013 16:51:53 GMT
        #     X-Account-Bytes-Used:         23423433
        #     X-Account-Container-Count:    2
        #     X-Account-Object-Count:       10
        #
        # If we wan't to go back to our original admin account:
        #
        #     service.reset_account_name
        #
        def change_account(account)
          @original_path ||= @path
          version_string = @path.split('/')[1]
          @path = "/#{version_string}/#{account}"
        end

        def reset_account_name
          @path = @original_path
        end
      end
    end
  end
end
