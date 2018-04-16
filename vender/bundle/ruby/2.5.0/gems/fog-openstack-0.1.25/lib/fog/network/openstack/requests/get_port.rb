module Fog
  module Network
    class OpenStack
      class Real
        def get_port(port_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "ports/#{port_id}"
          )
        end
      end

      class Mock
        def get_port(port_id)
          response = Excon::Response.new
          if data = self.data[:ports][port_id]
            response.status = 200
            response.body = {
              'port' => {
                'id'                    => '5c81d975-5fea-4674-9c1f-b8aa10bf9a79',
                'name'                  => 'port_1',
                'network_id'            => 'e624a36d-762b-481f-9b50-4154ceb78bbb',
                'fixed_ips'             => [
                  {
                    'ip_address' => '10.2.2.2',
                    'subnet_id'  => '2e4ec6a4-0150-47f5-8523-e899ac03026e',
                  }
                ],
                'mac_address'           => 'fa:16:3e:62:91:7f',
                'status'                => 'ACTIVE',
                'admin_state_up'        => true,
                'device_id'             => 'dhcp724fc160-2b2e-597e-b9ed-7f65313cd73f-e624a36d-762b-481f-9b50-4154ceb78bbb',
                'device_owner'          => 'network:dhcp',
                'tenant_id'             => 'f8b26a6032bc47718a7702233ac708b9',
                'security_groups'       => ['3ddde803-e550-4737-b5de-0862401dc834'],
                'allowed_address_pairs' => [
                  'ip_address'  => '10.1.1.1',
                  'mac_address' => 'fa:16:3e:3d:2a:cc'
                ]
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
