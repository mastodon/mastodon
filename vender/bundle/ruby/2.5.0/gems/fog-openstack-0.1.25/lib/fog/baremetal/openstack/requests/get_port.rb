module Fog
  module Baremetal
    class OpenStack
      class Real
        def get_port(port_id)
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => "ports/#{port_id}"
          )
        end
      end # class Real

      class Mock
        def get_port(_port_id)
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = data[:ports].first
          response
        end # def get_port
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
