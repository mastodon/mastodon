module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def get_tenant(id)
            request(
              :expects => [200, 204],
              :method  => 'GET',
              :path    => "tenants/#{id}"
            )
          end
        end # class Real

        class Mock
          def get_tenant(id)
            response = Excon::Response.new
            response.status = [200, 204][rand(2)]
            response.body = {
              'tenant' => {
                'id'          => id,
                'description' => 'Has access to everything',
                'enabled'     => true,
                'name'        => 'admin'
              }
            }
            response
          end # def list_tenants
        end # class Mock
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog
