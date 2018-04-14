module Fog
  module Compute
    class OpenStack
      class Real
        def allocate_address(pool = nil)
          request(
            :body    => Fog::JSON.encode('pool' => pool),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => 'os-floating-ips'
          )
        end
      end

      class Mock
        def allocate_address(_pool = nil)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-d4a21158-a86c-44a6-983a-e25645907f26",
            "Content-Type"         => "application/json",
            "Content-Length"       => "105",
            "Date"                 => Date.new
          }
          response.body = {
            "floating_ip" => {
              "instance_id" => nil,
              "ip"          => "192.168.27.132",
              "fixed_ip"    => nil,
              "id"          => 4,
              "pool"        => "nova"
            }
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end
