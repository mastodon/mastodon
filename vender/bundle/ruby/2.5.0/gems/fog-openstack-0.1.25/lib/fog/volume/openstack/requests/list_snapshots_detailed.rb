module Fog
  module Volume
    class OpenStack
      module Real
        def list_snapshots_detailed(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'snapshots/detail',
            :query   => options
          )
        end
      end

      module Mock
        def list_snapshots_detailed(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'snapshots' => [get_snapshot_details.body["snapshot"]]
          }
          response
        end
      end
    end
  end
end
