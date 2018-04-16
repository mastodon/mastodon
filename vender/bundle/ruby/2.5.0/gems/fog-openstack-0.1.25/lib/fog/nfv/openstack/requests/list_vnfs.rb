module Fog
  module NFV
    class OpenStack
      class Real
        def list_vnfs(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "vnfs",
            :query   => options
          )
        end
      end

      class Mock
        def list_vnfs(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {"vnfs" => data[:vnfs]}
          response
        end
      end
    end
  end
end
