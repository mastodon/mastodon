module Fog
  module DNS
    class OpenStack
      class V1
        class Real
          def get_quota(project_id)
            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "quotas/#{project_id}"
            )
          end
        end

        class Mock
          def get_quota(_project_id)
            response = Excon::Response.new
            response.status = 200
            response.body = data[:quota_updated] || data[:quota]
            response
          end
        end
      end
    end
  end
end
