module Fog
  module Network
    class OpenStack
      class Real
        def list_network_ip_availabilities
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "network-ip-availabilities"
          )
        end
      end

      class Mock
        def list_network_ip_availabilities
          response = Excon::Response.new
          if data = self.data[:network_ip_availabilities]
            response.status = 200
            response.body = {'network_ip_availabilities' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
