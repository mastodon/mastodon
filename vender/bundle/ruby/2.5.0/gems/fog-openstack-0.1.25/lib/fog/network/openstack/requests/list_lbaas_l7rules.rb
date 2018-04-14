module Fog
  module Network
    class OpenStack
      class Real
        def list_lbaas_l7rules(l7policy_id, filters = {})
          request(
              :expects => 200,
              :method  => 'GET',
              :path    => "lbaas/l7policies/#{l7policy_id}/rules",
              :query   => filters
          )
        end
      end

      class Mock
        def list_lbaas_l7rules(l7policy_id, filters = {})
          Excon::Response.new(
              :body   => {'rules' => data[:lbaas_l7rules].values},
              :status => 200
          )
        end
      end
    end
  end
end
