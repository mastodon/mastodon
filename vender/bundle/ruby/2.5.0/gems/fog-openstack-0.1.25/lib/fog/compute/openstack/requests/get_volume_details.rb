module Fog
  module Compute
    class OpenStack
      class Real
        def get_volume_details(volume_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "os-volumes/#{volume_id}"
          )
        end
      end

      class Mock
        def get_volume_details(volume_id)
          response = Excon::Response.new
          if data = self.data[:volumes][volume_id]
            if data['status'] == 'creating' \
               && Time.now - Time.parse(data['createdAt']) >= Fog::Mock.delay
              data['status'] = 'available'
            end
            response.status = 200
            response.body = {'volume' => data}
            response
          else
            raise Fog::Compute::OpenStack::NotFound
          end
        end
      end
    end
  end
end
