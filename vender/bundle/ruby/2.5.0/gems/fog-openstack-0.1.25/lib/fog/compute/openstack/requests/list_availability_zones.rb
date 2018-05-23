module Fog
  module Compute
    class OpenStack
      class Real
        def list_availability_zones(options = {})
          params = options

          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "os-availability-zone",
            :query   => params
          )
        end
      end

      class Mock
        def list_endpoints
        end
      end
    end
  end
end
