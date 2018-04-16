module Fog
  module Network
    class OpenStack
      class Real
        def delete_lbaas_l7rule(l7policy_id, l7rule_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lbaas/l7policies/#{l7policy_id}/rules/#{l7rule_id}"
          )
        end
      end

      class Mock
        def delete_lbaas_l7rule(l7policy_id, l7rule_id)
          response = Excon::Response.new
          if list_lbaas_l7rules.body['l7rules'].map { |r| r['id'] }.include? l7rule_id
            data[:lbaas_l7rules].delete(l7rule_id)
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
