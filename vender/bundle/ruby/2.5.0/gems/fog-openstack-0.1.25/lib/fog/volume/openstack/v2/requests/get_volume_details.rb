require 'fog/volume/openstack/requests/get_volume_details'

module Fog
  module Volume
    class OpenStack
      class V2
        class Real
          include Fog::Volume::OpenStack::Real
        end

        class Mock
          def get_volume_details(_detailed = true)
            response        = Excon::Response.new
            response.status = 200
            response.body   = {
              'volume' => {
                'id'                => '1',
                'name'              => Fog::Mock.random_letters(rand(8) + 5),
                'description'       => Fog::Mock.random_letters(rand(12) + 10),
                'size'              => 3,
                'volume_type'       => nil,
                'snapshot_id'       => '4',
                'status'            => 'online',
                'availability_zone' => 'nova',
                'created_at'        => Time.now,
                'attachments'       => []
              }
            }
            response
          end
        end
      end
    end
  end
end
