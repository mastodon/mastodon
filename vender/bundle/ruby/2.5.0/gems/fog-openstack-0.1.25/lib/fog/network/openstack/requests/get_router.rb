module Fog
  module Network
    class OpenStack
      class Real
        def get_router(router_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "routers/#{router_id}"
          )
        end
      end

      class Mock
        def get_router(router_id)
          response = Excon::Response.new
          if data = (self.data[:routers].find { |id, _value| id == router_id })
            response.status = 200
            response.body = {
              'router' => data[1],
            }
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
