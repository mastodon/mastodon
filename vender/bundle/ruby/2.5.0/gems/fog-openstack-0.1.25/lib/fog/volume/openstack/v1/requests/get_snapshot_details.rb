require 'fog/volume/openstack/requests/get_snapshot_details'

module Fog
  module Volume
    class OpenStack
      class V1
        class Real
          include Fog::Volume::OpenStack::Real
        end

        class Mock
          def get_snapshot_details(_detailed = true)
            response        = Excon::Response.new
            response.status = 200
            response.body   = {
              'snapshot' => {
                'id'                  => '1',
                'display_name'        => 'Snapshot1',
                'display_description' => 'Volume1 snapshot',
                'size'                => 1,
                'volume_id'           => '1',
                'status'              => 'available',
                'created_at'          => Time.now
              }
            }
            response
          end
        end
      end
    end
  end
end
