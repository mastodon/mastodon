module Fog
  module Compute
    class OpenStack
      class Real
        def list_images_detail(filters = {})
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'images/detail',
            :query   => filters
          )
        end
      end

      class Mock
        def list_images_detail(_filters = {})
          response = Excon::Response.new

          images = data[:images].values
          images.each do |image|
            case image['status']
            when 'SAVING'
              if Time.now - data[:last_modified][:images][image['id']] >= Fog::Mock.delay
                image['status'] = 'ACTIVE'
              end
            end
          end

          response.status = [200, 203][rand(2)]
          response.body = {'images' => images.map { |image| image.reject { |key, _value| !['id', 'name', 'links', 'minRam', 'minDisk', 'metadata', 'status', 'updated'].include?(key) } }}
          response
        end
      end
    end
  end
end
