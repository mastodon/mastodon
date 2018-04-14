module Fog
  module Baremetal
    class OpenStack
      class Real
        def list_chassis(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'chassis',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_chassis(_parameters = nil)
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {
            "chassis" => [
              {
                "description" => "Sample chassis",
                "links"       => [
                  {
                    "href" => "http =>//localhost:6385/v1/chassis/eaaca217-e7d8-47b4-bb41-3f99f20eed89",
                    "rel"  => "self"
                  },
                  {
                    "href" => "http =>//localhost:6385/chassis/eaaca217-e7d8-47b4-bb41-3f99f20eed89",
                    "rel"  => "bookmark"
                  }
                ],
                "uuid"        => Fog::UUID.uuid
              }
            ]
          }
          response
        end # def list_chassis
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
