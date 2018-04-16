module Fog
  module Compute
    class OpenStack
      class Real
        def list_hypervisors(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-hypervisors',
            :query   => options
          )
        end
      end

      class Mock
        def list_hypervisors(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'hypervisors' => [
            {"hypervisor_hostname" => "fake-mini", "id" => 2, "state" => "up", "status" => "enabled"}
          ]}
          response
        end
      end
    end
  end
end
