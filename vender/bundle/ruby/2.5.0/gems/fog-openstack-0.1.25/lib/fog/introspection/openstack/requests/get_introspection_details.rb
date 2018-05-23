module Fog
  module Introspection
    class OpenStack
      class Real
        def get_introspection_details(node_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "introspection/#{node_id}/data"
          )
        end
      end

      class Mock
        def get_introspection_details(_node_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {"data" => data[:introspection_data]}
          response
        end
      end
    end
  end
end
