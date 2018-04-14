module Fog
  module Metering
    class OpenStack
      class Real
        def list_meters(options = [])
          data = {
            'q' => []
          }

          options.each do |opt|
            filter = {}

            ['field', 'op', 'value'].each do |key|
              filter[key] = opt[key] if opt[key]
            end

            data['q'] << filter unless filter.empty?
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'GET',
            :path    => 'meters'
          )
        end
      end

      class Mock
        def list_meters(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [{
            'user_id'     => '1d5fd9eda19142289a60ed9330b5d284',
            'name'        => 'image.size',
            'resource_id' => 'glance',
            'project_id'  => 'd646b40dea6347dfb8caee2da1484c56',
            'type'        => 'gauge',
            'unit'        => 'bytes'
          }]
          response
        end
      end
    end
  end
end
