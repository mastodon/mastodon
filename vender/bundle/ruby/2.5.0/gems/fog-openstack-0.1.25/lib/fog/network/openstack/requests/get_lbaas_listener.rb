module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_listener(listener_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/listeners/#{listener_id}"
          )
        end
      end

      class Mock
        def get_lbaas_listener(listener_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_listeners][listener_id]
            response.status = 200
            response.body = {'listener' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
