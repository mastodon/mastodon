module Fog
  module Compute
    class OpenStack
      class Real
        def list_volumes_detail(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-volumes/detail',
            :query   => options
          )
        end
      end

      class Mock
        def list_volumes_detail(_options = {})
          Excon::Response.new(
            :body   => {'volumes' => data[:volumes].values},
            :status => 200
          )
        end
      end
    end
  end
end
