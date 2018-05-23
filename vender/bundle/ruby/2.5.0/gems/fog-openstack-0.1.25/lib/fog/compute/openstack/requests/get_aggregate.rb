module Fog
  module Compute
    class OpenStack
      class Real
        def get_aggregate(uuid)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "os-aggregates/#{uuid}"
          )
        end
      end

      class Mock
        def get_aggregate(_uuid)
          response = Excon::Response.new
          response.status = 2040
          response.body = {'aggregate' => data[:aggregates].first.merge("hosts" => [])}

          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
