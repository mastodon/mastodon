require 'fog/volume/openstack/requests/create_volume'

module Fog
  module Volume
    class OpenStack
      class V2
        class Real
          def create_volume(name, description, size, options = {})
            data = {
              'volume' => {
                'name'        => name,
                'description' => description,
                'size'        => size
              }
            }

            _create_volume(data, options)
          end

          include Fog::Volume::OpenStack::Real
        end

        class Mock
          def create_volume(name, description, size, options = {})
            response        = Excon::Response.new
            response.status = 202
            response.body   = {
              'volume' => {
                'id'                => Fog::Mock.random_numbers(2),
                'name'              => name,
                'description'       => description,
                'metadata'          => options['metadata'] || {},
                'size'              => size,
                'status'            => 'creating',
                'snapshot_id'       => options[:snapshot_id] || nil,
                'image_id'          => options[:imageRef] || nil,
                'volume_type'       => nil,
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
