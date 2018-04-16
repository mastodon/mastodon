module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_pools(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lbaas/pools',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_pools(_filters = {})
          Excon::Response.new(
            :body   => {'pools' => data[:lbaas_pools].values},
            :status => 200
          )
        end
      end
    end
  end
end
