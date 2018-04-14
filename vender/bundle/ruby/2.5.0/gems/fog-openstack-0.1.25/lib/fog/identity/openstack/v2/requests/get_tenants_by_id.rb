module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def get_tenants_by_id(tenant_id)
            request(
              :expects => [200],
              :method  => 'GET',
              :path    => "tenants/#{tenant_id}"
            )
          end
        end

        class Mock
        end
      end # class V2
    end
  end
end
