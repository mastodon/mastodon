module Fog
  module SharedFileSystem
    class OpenStack
      class Real
        def get_quota(project_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "#{action_prefix}quota-sets/#{project_id}"
          )
        end
      end

      class Mock
        def get_quota(project_id)
          response = Excon::Response.new
          response.status = 200
          quota_data = data[:quota_updated] || data[:quota]
          quota_data['id'] = project_id
          response.body = {'quota_set' => quota_data}
          response
        end
      end
    end
  end
end
