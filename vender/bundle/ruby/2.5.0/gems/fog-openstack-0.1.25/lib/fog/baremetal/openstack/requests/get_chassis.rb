module Fog
  module Baremetal
    class OpenStack
      class Real
        def get_chassis(chassis_uuid)
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => "chassis/#{chassis_uuid}"
          )
        end
      end # class Real

      class Mock
        def get_chassis(_chassis_uuid)
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = data[:chassis_collection].first
          response
        end # def get_chassis
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
