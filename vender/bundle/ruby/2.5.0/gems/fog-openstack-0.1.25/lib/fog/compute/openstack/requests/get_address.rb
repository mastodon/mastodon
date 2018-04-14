module Fog
  module Compute
    class OpenStack
      class Real
        def get_address(address_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "os-floating-ips/#{address_id}"
          )
        end
      end

      class Mock
        def get_address(_address_id)
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
              "ip"          => "192.168.27.129",
              "fixed_ip"    => nil,
              "id"          => 1,
              "pool"        => "nova"
            }
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
