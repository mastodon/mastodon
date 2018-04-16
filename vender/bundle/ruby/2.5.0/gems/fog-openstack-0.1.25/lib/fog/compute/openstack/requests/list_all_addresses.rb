module Fog
  module Compute
    class OpenStack
      class Real
        def list_all_addresses(options = {})
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "os-floating-ips",
            :query   => options
          )
        end
      end

      class Mock
        def list_all_addresses(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-d4a21158-a86c-44a6-983a-e25645907f26",
            "Content-Type"         => "application/json",
            "Content-Length"       => "378",
            "Date"                 => Date.new
          }
          response.body = {
            "floating_ips" => [
              {
                "instance_id" => nil,
                "ip"          => "192.168.27.129",
                "fixed_ip"    => nil,
                "id"          => 1,
                "pool"        => "nova"
              },
              {
                "instance_id" => nil,
                "ip"          => "192.168.27.130",
                "fixed_ip"    => nil,
                "id"          => 2,
                "pool"        => "nova"
              },
              {
                "instance_id" => nil,
                "ip"          => "192.168.27.131",
                "fixed_ip"    => nil,
                "id"          => 3,
                "pool"        => "nova"
              },
              {
                "instance_id" => nil,
                "ip"          => "192.168.27.132",
                "fixed_ip"    => nil,
                "id"          => 4,
                "pool"        => "nova"
              }
            ]
          }
          response
        end
      end # mock
    end # openstack
  end # Compute
end # fog
