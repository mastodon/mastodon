module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def update_image(id, json_patch)
            request(
              :headers => {'Content-Type' => 'application/openstack-images-v2.1-json-patch'},
              :expects => [200],
              :method  => 'PATCH',
              :path    => "images/#{id}",
              :body    => Fog::JSON.encode(json_patch)
            )
          end
        end

        class Mock
          def update_image(attributes)
            response = Excon::Response.new
            response.status = 200
            image = images.last
            response.body = {
              'image' => {
                'name'             => attributes[:name] || image.name,
                'size'             => image.size,
                'min_disk'         => (attributes[:min_disk] || image.min_disk).to_i,
                'disk_format'      => attributes[:disk_format] || image.disk_format,
                'created_at'       => image.created_at,
                'container_format' => attributes[:container_format] || image.container_format,
                'deleted_at'       => nil,
                'updated_at'       => Time.now.to_s,
                'checksum'         => image.checksum,
                'id'               => attributes[:id],
                'deleted'          => false,
                'protected'        => false,
                'is_public'        => attributes[:is_public] || image.is_public,
                'status'           => image.status,
                'min_ram'          => (attributes[:min_ram] || image.min_ram).to_i,
                'owner'            => attributes[:owner] || image.owner,
                'properties'       => attributes[:properties] || image.properties
              }
            }
            response
          end
        end
      end
    end
  end
end
