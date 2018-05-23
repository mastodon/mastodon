module Fog
  module Compute
    class OpenStack
      class Real
        def list_images
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'images'
          )
        end
      end

      class Mock
        def list_images
          response = Excon::Response.new
          data = list_images_detail.body['images']
          images = []
          data.each do |image|
            images << image.reject { |key, _value| !['id', 'name', 'links'].include?(key) }
          end
          response.status = [200, 203][rand(2)]
          response.body = {'images' => images}
          response
        end
      end
    end
  end
end
