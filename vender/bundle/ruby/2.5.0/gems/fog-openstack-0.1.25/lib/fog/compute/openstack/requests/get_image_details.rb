module Fog
  module Compute
    class OpenStack
      class Real
        def get_image_details(image_id)
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "images/#{image_id}"
          )
        end
      end

      class Mock
        def get_image_details(image_id)
          response = Excon::Response.new
          image = list_images_detail.body['images'].find { |im| im['id'] == image_id }
          if image
            response.status = [200, 203][rand(2)]
            response.body = {'image' => image}
            response
          else
            raise Fog::Compute::OpenStack::NotFound
          end
        end
      end
    end
  end
end
