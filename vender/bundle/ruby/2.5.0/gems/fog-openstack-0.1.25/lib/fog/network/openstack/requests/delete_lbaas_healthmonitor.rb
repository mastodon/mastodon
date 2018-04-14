module Fog
  module Network
    class OpenStack
      class Real
        def delete_lbaas_healthmonitor(healthmonitor_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lbaas/healthmonitors/#{healthmonitor_id}"
          )
        end
      end

      class Mock
        def delete_lbaas_healthmonitor(healthmonitor_id)
          response = Excon::Response.new
          if list_lbaas_healthmonitors.body['healthmonitors'].map { |r| r['id'] }.include? healthmonitor_id
            data[:lbaas_healthmonitors].delete(healthmonitor_id)
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
