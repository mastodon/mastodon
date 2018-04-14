module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def deactivate_image(image_id)
            request(
              :expects => 204,
              :method  => 'POST',
              :path    => "images/#{image_id}/actions/deactivate"
            )
          end
        end

        class Mock
          def deactivate_image(_image_id)
            response = Excon::Response.new
            response.status = 204
            response
          end
        end
      end
    end
  end
end
