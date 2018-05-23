module Fog
  module Compute
    class OpenStack
      class Real
        def list_hypervisor_servers(hypervisor_id, options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "os-hypervisors/#{hypervisor_id}/servers",
            :query   => options
          )
        end
      end

      class Mock
        def list_hypervisor_servers(hypervisor_id, _options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'hypervisors' => [
            {
              "hypervisor_hostname" => "fake-mini",
              "id"                  => hypervisor_id,
              "state"               => "up",
              "status"              => "enabled",
              "servers"             => [
                {
                  "name" => "test_server1",
                  "uuid" => "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
                },
                {
                  "name" => "test_server2",
                  "uuid" => "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
                }
              ]
            }
          ]}
          response
        end
      end
    end
  end
end
