module Fog
  module Compute
    class OpenStack
      class Real
        def remove_aggregate_host(uuid, host_uuid)
          data = {'remove_host' => {'host' => host_uuid}}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'POST',
            :path    => "os-aggregates/#{uuid}/action"
          )
        end
      end

      class Mock
        def remove_aggregate_host(_uuid, _host_uuid)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
