module Fog
  module Network
    class OpenStack
      class Real
        def list_subnet_pools(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'subnetpools',
            :query   => filters
          )
        end
      end

      class Mock
        def list_subnet_pools(_filters = {})
          Excon::Response.new(
            :body   => {'subnetpools' => data[:subnet_pools].values},
            :status => 200
          )
        end
      end
    end
  end
end
