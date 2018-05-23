

module Fog
  module Volume
    class OpenStack < Fog::Service
      @@recognizes = [:openstack_auth_token, :openstack_management_url,
                      :persistent, :openstack_service_type, :openstack_service_name,
                      :openstack_tenant, :openstack_tenant_id,
                      :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                      :current_user, :current_tenant, :openstack_region,
                      :openstack_endpoint_type, :openstack_cache_ttl,
                      :openstack_project_name, :openstack_project_id,
                      :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                      :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                      :openstack_identity_prefix]

      # Fog::Image::OpenStack.new() will return a Fog::Volume::OpenStack::V2 or a Fog::Volume::OpenStack::V1,
      #  choosing the V2 by default, as V1 is deprecated since OpenStack Juno
      def self.new(args = {})
        @openstack_auth_uri = URI.parse(args[:openstack_auth_url]) if args[:openstack_auth_url]
        service = if inspect == 'Fog::Volume::OpenStack'
                    Fog::Volume::OpenStack::V2.new(args) || Fog::Volume::OpenStack::V1.new(args)
                  else
                    super
                  end
        service
      end
    end
  end
end
