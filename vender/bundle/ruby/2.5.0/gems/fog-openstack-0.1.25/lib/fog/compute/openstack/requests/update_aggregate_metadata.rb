module Fog
  module Compute
    class OpenStack
      class Real
        def update_aggregate_metadata(uuid, metadata = {})
          data = {'set_metadata' => {'metadata' => metadata}}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200],
            :method  => 'POST',
            :path    => "os-aggregates/#{uuid}/action"
          )
        end
      end

      class Mock
        def update_aggregate_metadata(_uuid, _metadata = {})
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
