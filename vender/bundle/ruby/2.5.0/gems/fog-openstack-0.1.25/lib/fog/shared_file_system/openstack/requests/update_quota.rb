module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def update_quota(project_id, options = {})
          request(
            :body    => Fog::JSON.encode('quota_set' => options),
            :expects => 200,
            :method  => 'PUT',
            :path    => "#{action_prefix}quota-sets/#{project_id}"
          )
        end
      end

      class Mock
        def update_quota(project_id, options = {})
          # stringify keys
          options = Hash[options.map { |k, v| [k.to_s, v] }]
          data[:quota_updated] = data[:quota].merge(options)
          data[:quota_updated]['id'] = project_id

          response = Excon::Response.new
          response.status = 200
          response.body = {'quota_set' => data[:quota_updated]}
          response
        end
      end
    end
  end
end
