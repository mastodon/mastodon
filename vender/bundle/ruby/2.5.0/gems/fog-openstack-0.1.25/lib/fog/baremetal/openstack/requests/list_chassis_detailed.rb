module Fog
  module Baremetal
    class OpenStack
      class Real
        def list_chassis_detailed(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'chassis/detail',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_chassis_detailed(_options = {})
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {"chassis" => data[:chassis_collection]}
          response
        end # def list_chassis_detailed
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
