module Fog
  module NFV
    class OpenStack
      class Real
        def list_vnfds(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "vnfds",
            :query   => options
          )
        end
      end

      class Mock
        def list_vnfds(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {"vnfds" => data[:vnfds]}
          response
        end
      end
    end
  end
end
