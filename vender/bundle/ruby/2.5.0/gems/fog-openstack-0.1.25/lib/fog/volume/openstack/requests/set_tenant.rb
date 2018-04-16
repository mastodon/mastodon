module Fog
  module Volume
    class OpenStack
      module Real
        def set_tenant(tenant)
          @openstack_must_reauthenticate = true
          @openstack_tenant = tenant.to_s
          authenticate
        end
      end

      module Mock
        def set_tenant(_tenant)
          true
        end
      end
    end # class OpenStack
  end # module Volume
end # module Fog
