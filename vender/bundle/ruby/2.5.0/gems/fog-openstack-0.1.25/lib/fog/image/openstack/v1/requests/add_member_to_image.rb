module Fog
  module Image
    class OpenStack
      class V1
        class Real
          def add_member_to_image(image_id, tenant_id)
            request(
              :expects => [200, 204],
              :method  => 'PUT',
              :path    => "images/#{image_id}/members/#{tenant_id}"
            )
          end
        end # class Real

        class Mock
          def add_member_to_image(_image_id, _tenant_id)
            response = Excon::Response.new
            response.status = [200, 204][rand(2)]
            response
          end # def list_tenants
        end # class Mock
      end # class V1
    end # class OpenStack
  end # module Identity
end # module Fog
