module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_listeners(filters = {})
          request(
              :expects => 200,
              :method => 'GET',
              :path => 'lbaas/listeners',
              :query => filters
          )
        end
      end

      class Mock
        def list_lbaas_listeners(_filters = {})
          Excon::Response.new(
              :body => {'listeners' => data[:lbaas_listeners].values},
              :status => 200
          )
        end
      end
    end
  end
end
