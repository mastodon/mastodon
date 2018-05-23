module Fog
  module Baremetal
    class OpenStack
      class Real
        def list_ports(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'ports',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_ports(_options = {})
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {
            "ports" => [
              {
                "address" => "fe:54:00:77:07:d9",
                "links"   => [
                  {
                    "href" => "http://localhost:6385/v1/ports/27e3153e-d5bf-4b7e-b517-fb518e17f34c",
                    "rel"  => "self"
                  },
                  {
                    "href" => "http://localhost:6385/ports/27e3153e-d5bf-4b7e-b517-fb518e17f34c",
                    "rel"  => "bookmark"
                  }
                ],
                "uuid"    => Fog::UUID.uuid
              }
            ]
          }
          response
        end # def list_ports
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
