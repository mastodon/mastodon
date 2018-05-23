module Fog
  module Volume
    class OpenStack
      module Real
        def get_quota_usage(tenant_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "/os-quota-sets/#{tenant_id}?usage=True"
          )
        end
      end

      module Mock
        def get_quota_usage(tenant_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'quota_set' => {
              'gigabytes' => {
                'reserved' => 0,
                'limit'    => -1,
                'in_use'   => 160
              },
              'snapshots' => {
                'reserved' => 0,
                'limit'    => 50,
                'in_use'   => 3
              },
              'volumes'   => {
                'reserved' => 0,
                'limit'    => 50,
                'in_use'   => 5
              },
              'id'        => tenant_id
            }
          }
          response
        end
      end
    end
  end
end
