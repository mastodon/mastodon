module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_healthmonitors(filters = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'lbaas/healthmonitors',
            :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_healthmonitors(_filters = {})
          Excon::Response.new(
            :body   => {'healthmonitors' => data[:lbaas_healthmonitors].values},
            :status => 200
          )
        end
      end
    end
  end
end
