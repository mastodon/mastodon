module Fog
  module Compute
    class OpenStack
      class Real
        def update_quota(tenant_id, options = {})
          request(
            :body    => Fog::JSON.encode('quota_set' => options),
            :expects => 200,
            :method  => 'PUT',
            :path    => "/os-quota-sets/#{tenant_id}"
          )
        end
      end

      class Mock
        def update_quota(_tenant_id, options = {})
          data[:quota_updated] = data[:quota].merge options

          response = Excon::Response.new
          response.status = 200
          response.body = {'quota_set' => data[:quota_updated]}
          response
        end
      end
    end
  end
end
