module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def create_image(image)
            location = image.delete :location
            headers = {}
            headers["Location"] = location if location

            request(
              :headers => headers,
              :expects => [201],
              :method  => 'POST',
              :path    => "images",
              :body    => Fog::JSON.encode(image)
            )
          end
        end

        class Mock
          def create_image(attributes)
            response = Excon::Response.new
            response.status = 201

            image_id = Fog::Mock.random_hex(32)
            image = data[:images][image_id] = {
              'tags'             => attributes[:tags] || [],
              'name'             => attributes[:name],
              'size'             => nil,
              'min_disk'         => attributes[:min_disk] || 0,
              'disk_format'      => attributes[:disk_format] || 'raw',
              'created_at'       => Time.now.strftime('%FT%T.%6N'),
              'container_format' => attributes[:container_format] || 'bare',
              'deleted_at'       => nil,
              'updated_at'       => Time.now.strftime('%FT%T.%6N'),
              'checksum'         => nil,
              'id'               => image_id,
              'visibility'       => attributes[:visibility] || 'public',
              'status'           => 'queued',
              'min_ram'          => attributes[:min_ram] || 0,
              'owner'            => attributes[:owner] || Fog::Mock.random_hex(32)
            }
            response.body = image
            response
          end
        end
      end
    end
  end
end
