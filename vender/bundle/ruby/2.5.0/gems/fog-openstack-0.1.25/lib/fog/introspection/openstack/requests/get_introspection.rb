module Fog
  module Introspection
    class OpenStack
      class Real
        def get_introspection(node_id)
          request(
            :expects => 200,
            :method  => "GET",
            :path    => "introspection/#{node_id}"
          )
        end
      end

      class Mock
        def get_introspection(_node_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {"error" => "null", "finished" => "true"}
          response
        end
      end
    end
  end
end
