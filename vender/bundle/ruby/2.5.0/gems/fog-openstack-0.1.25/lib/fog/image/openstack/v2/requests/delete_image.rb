module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def delete_image(image_id)
            request(
              :expects => 204,
              :method  => 'DELETE',
              :path    => "images/#{image_id}"
            )
          end
        end

        class Mock
          def delete_image(_image_id)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end
