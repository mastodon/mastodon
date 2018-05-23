module Fog
  module Network
    class OpenStack
      class Real
        def get_network_ip_availability(network_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "network-ip-availabilities/#{network_id}"
          )
        end
      end

      class Mock
        def get_network_ip_availability(network_id)
          response = Excon::Response.new
          if data = self.data[:network_ip_availabilities].first
            response.status = 200
            response.body = {'network_ip_availability' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
