require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/tenant'

module Fog
  module Compute
    class OpenStack
      class Tenants < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::Tenant

        def all
          load_response(service.list_tenants, 'tenants')
        end

        def usages(start_date = nil, end_date = nil, details = false)
          service.list_usages(start_date, end_date, details).body['tenant_usages']
        end

        def get(id)
          find { |tenant| tenant.id == id }
        end
      end # class Tenants
    end # class OpenStack
  end # module Compute
end # module Fog
