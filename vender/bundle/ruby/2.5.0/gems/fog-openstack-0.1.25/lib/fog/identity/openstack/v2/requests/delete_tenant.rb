module Fog
  module Identity
    class OpenStack
      class V2
        class Real
          def delete_tenant(id)
            request(
              :expects => [200, 204],
              :method  => 'DELETE',
              :path    => "tenants/#{id}"
            )
          end # def create_tenant
        end # class Real

        class Mock
          def delete_tenant(_attributes)
            response = Excon::Response.new
            response.status = [200, 204][rand(2)]
            response.body = {
              'tenant' => {
                'id'          => '1',
                'description' => 'Has access to everything',
                'enabled'     => true,
                'name'        => 'admin'
              }
            }
            response
          end # def create_tenant
        end # class Mock
      end # class V2
    end # class OpenStack
  end # module Identity
end # module Fog
