module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def get_quota(project_id = nil)
            headers, _options = Fog::DNS::OpenStack::V2.setup_headers(:all_projects => !project_id.nil?)

            request(
              :expects => 200,
              :method  => 'GET',
              :path    => "quotas/#{project_id}",
              :headers => headers
            )
          end
        end

        class Mock
          def get_quota(_project_id = nil)
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
