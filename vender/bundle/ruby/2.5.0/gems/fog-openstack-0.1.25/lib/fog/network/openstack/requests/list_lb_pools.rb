module Fog
  module Network
    class OpenStack
      class Real
        def list_lb_pools(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lb/pools',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lb_pools(_filters = {})
          Excon::Response.new(
            :body   => {'pools' => data[:lb_pools].values},
            :status => 200
          )
        end
      end
    end
  end
end
