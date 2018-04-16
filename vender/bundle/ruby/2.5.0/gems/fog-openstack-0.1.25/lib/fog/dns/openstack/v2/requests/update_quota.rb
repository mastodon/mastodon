module Fog
  module DNS
    class OpenStack
      class V2
        class Real
          def update_quota(project_id, options = {})
            headers, options = Fog::DNS::OpenStack::V2.setup_headers(options)

            request(
              :body    => Fog::JSON.encode(options),
              :expects => 200,
              :method  => 'PATCH',
              :path    => "quotas/#{project_id}",
              :headers => headers
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
