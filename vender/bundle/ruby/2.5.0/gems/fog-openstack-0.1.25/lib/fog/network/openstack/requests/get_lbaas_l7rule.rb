module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_l7rule(l7policy_id, l7rule_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/l7policies/#{l7policy_id}/rules/#{l7rule_id}"
          )
        end
      end

      class Mock
        def get_lbaas_l7rule(l7policy_id, l7rule_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_l7rules][l7rule_id]
            response.status = 200
            response.body = {'rule' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
