module Fog
  module Metering
    class OpenStack
      class Real
        def list_resources(_options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'resources'
          )
        end
      end

      class Mock
        def list_resources(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [{
            'resource_id' => 'glance',
            'project_id'  => 'd646b40dea6347dfb8caee2da1484c56',
            'user_id'     => '1d5fd9eda19142289a60ed9330b5d284',
            'metadata'    => {}
          }]
          response
        end
      end
    end
  end
end
