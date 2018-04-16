module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def list_snapshots(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'snapshots',
            :query   => options
          )
        end
      end

      class Mock
        def list_snapshots(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {'snapshots' => data[:snapshots]}
          response
        end
      end
    end
  end
end
