module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_snapshots_detail(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'snapshots/detail',
            :query   => options
          )
        end
      end

      class Mock
        def list_snapshots_detail(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'snapshots' => data[:snapshots_detail]}
          response
        end
      end
    end
  end
end
