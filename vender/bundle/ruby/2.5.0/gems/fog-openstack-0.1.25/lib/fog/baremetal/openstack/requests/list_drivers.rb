module Fog
  module Baremetal
    class OpenStack
      class Real
        def list_drivers(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'drivers',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_drivers(_options = {})
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {"drivers" => data[:drivers]}
          response
        end # def list_drivers
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
