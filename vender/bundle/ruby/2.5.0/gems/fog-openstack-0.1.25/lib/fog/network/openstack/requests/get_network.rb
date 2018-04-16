module Fog
  module Network
    class OpenStack
      class Real
        def get_network(network_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "networks/#{network_id}"
          )
        end
      end

      class Mock
        def get_network(network_id)
          response = Excon::Response.new
          if data = self.data[:networks][network_id]
            response.status = 200
            response.body = {'network' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
