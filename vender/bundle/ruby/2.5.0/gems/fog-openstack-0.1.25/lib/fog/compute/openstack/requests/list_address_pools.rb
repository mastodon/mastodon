module Fog
  module Compute
    class OpenStack
      class Real
        def list_address_pools
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "os-floating-ip-pools"
          )
        end
      end

      class Mock
        def list_address_pools
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'floating_ip_pools' => [
              {'name' => 'nova'}
            ]
          }
          response
        end
      end
    end
  end
end
