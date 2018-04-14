module Fog
  module Baremetal
    class OpenStack
      class Real
        def delete_chassis(chassis_uuid)
          data = {:chassis_uuid => chassis_uuid}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 204],
            :method  => 'DELETE',
            :path    => 'chassis'
          )
        end
      end

      class Mock
        def delete_chassis(_chassis_uuid)
          response = Excon::Response.new
          response.status = 200
          response
        end
      end
    end
  end
end
