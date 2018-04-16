module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_l7policies(filters = {})
          request(
              :expects => 200,
              :method  => 'GET',
              :path    => "lbaas/l7policies",
              :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_l7policies(filters = {})
          Excon::Response.new(
              :body   => {'l7policies' => data[:lbaas_l7policies].values},
              :status => 200
          )
        end
      end
    end
  end
end
