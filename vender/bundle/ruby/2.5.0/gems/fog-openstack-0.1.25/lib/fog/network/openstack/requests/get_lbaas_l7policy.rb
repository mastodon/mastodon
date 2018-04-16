module Fog
  module Network
    class OpenStack
      class Real
        def get_lbaas_l7policy(l7policy_id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "lbaas/l7policies/#{l7policy_id}"
          )
        end
      end

      class Mock
        def get_lbaas_l7policy(l7policy_id)
          response = Excon::Response.new
          if data = self.data[:lbaas_l7policies][l7policy_id]
            response.status = 200
            response.body = {'l7policy' => data}
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
