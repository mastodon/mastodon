module Fog
  module Network
    class OpenStack
      class Real
        def delete_quota(tenant_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "/quotas/#{tenant_id}"
          )
        end
      end

      class Mock
        def delete_quota(_tenant_id)
          response = Excon::Response.new
          response.status = 204
          response
        end
      end
    end
  end
end
