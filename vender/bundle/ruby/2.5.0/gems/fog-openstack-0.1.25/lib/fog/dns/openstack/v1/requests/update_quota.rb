module Fog
  module DNS
    class OpenStack
      class V1
        class Real
          def update_quota(project_id, options = {})
            request(
              :body    => Fog::JSON.encode(options),
              :expects => 200,
              :method  => 'PUT',
              :path    => "quotas/#{project_id}"
            )
          end
        end

        class Mock
          def update_quota(_project_id, options = {})
            # stringify keys
            options = Hash[options.map { |k, v| [k.to_s, v] }]
            data[:quota_updated] = data[:quota].merge(options)

            response = Excon::Response.new
            response.status = 200
            response.body = data[:quota_updated]
            response
          end
        end
      end
    end
  end
end
