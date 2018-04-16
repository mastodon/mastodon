module Fog
  module Network
    class OpenStack
      class Real
        def get_quota(tenant_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "/quotas/#{tenant_id}"
          )
        end
      end

      class Mock
        def get_quota(_tenant_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'quota' => (data[:quota_updated] || data[:quota])
          }
          response
        end
      end
    end
  end
end
