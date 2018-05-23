module Fog
  module Image
    class OpenStack
      class V2
        class Real
          def add_tag_to_image(image_id, tag)
            request(
              :expects => [204],
              :method  => 'PUT',
              :path    => "images/#{image_id}/tags/#{tag}"
            )
          end
        end # class Real

        class Mock
          def add_tag_to_image(_image_id, _tag)
            response = Excon::Response.new
            response.status = 204
            response
          end # def add_tag_to_image
        end # class Mock
      end # class OpenStack
    end
  end # module Image
end # module Fog
