module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_healthmonitor(healthmonitor_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/healthmonitors/#{healthmonitor_id}"
          )
        end
      end

      class Mock
        def get_lbaas_healthmonitor(healthmonitor_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_healthmonitors][healthmonitor_id]
            response.status = 200
            response.body = {'healthmonitor' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
