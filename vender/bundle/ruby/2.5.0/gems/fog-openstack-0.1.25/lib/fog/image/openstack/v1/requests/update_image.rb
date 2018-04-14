module Fog
  module Image
    class OpenStack
      class V1
        class Real
          def update_image(attributes)
            data = {
              'x-image-meta-name'             => attributes[:name],
              'x-image-meta-disk-format'      => attributes[:disk_format],
              'x-image-meta-container-format' => attributes[:container_format],
              'x-image-meta-size'             => attributes[:size],
              'x-image-meta-is-public'        => attributes[:is_public],
              'x-image-meta-min-ram'          => attributes[:min_ram],
              'x-image-meta-min-disk'         => attributes[:min_disk],
              'x-image-meta-checksum'         => attributes[:checksum],
              'x-image-meta-owner'            => attributes[:owner]
            }.reject { |_k, v| v.nil? }

            unless attributes[:properties].nil?
              attributes[:properties].each do |key, value|
                data["x-image-meta-property-#{key}"] = value
              end
            end

            request(
              :headers => data,
              :expects => 200,
              :method  => 'PUT',
              :path    => "images/#{attributes[:id]}"
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
