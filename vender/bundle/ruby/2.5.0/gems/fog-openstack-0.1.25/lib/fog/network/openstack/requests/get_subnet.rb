module Fog
  module Network
    class OpenStack
      class Real
        def get_subnet(subnet_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "subnets/#{subnet_id}"
          )
        end
      end

      class Mock
        def get_subnet(subnet_id)
          response = Excon::Response.new
          if data = self.data[:subnets][subnet_id]
            response.status = 200
            response.body = {
              "subnet" => {
                "id"               => "2e4ec6a4-0150-47f5-8523-e899ac03026e",
                "name"             => "subnet_1",
                "network_id"       => "e624a36d-762b-481f-9b50-4154ceb78bbb",
                "cidr"             => "10.2.2.0/24",
                "ip_version"       => 4,
                "gateway_ip"       => "10.2.2.1",
                "allocation_pools" => [
                  {
                    "start" => "10.2.2.2",
                    "end"   => "10.2.2.254"
                  }
                ],
                "dns_nameservers"  => [],
                "host_routes"      => [],
                "enable_dhcp"      => true,
                "tenant_id"        => "f8b26a6032bc47718a7702233ac708b9",
              }
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
