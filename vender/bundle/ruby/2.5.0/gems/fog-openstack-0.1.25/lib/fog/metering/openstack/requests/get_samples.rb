module Fog
  module Metering
    class OpenStack
      class Real
        def get_samples(meter_id, options = [], limit = 10000000)
          data = {
            'q' => []
          }

          options.each do |opt|
            filter = {}

            ['field', 'op', 'value'].each do |key|
              filter[key] = opt[key] if opt[key]
            end

            data['q'] << filter unless filter.empty?
            data['limit'] = limit
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'GET',
            :path    => "meters/#{meter_id}"
          )
        end
      end

      class Mock
        def get_samples(_meter_id)
          response = Excon::Response.new
          response.status = 200
          response.body = [{
            'counter_name'      => 'image.size',
            'user_id'           => '1d5fd9eda19142289a60ed9330b5d284',
            'resource_id'       => 'glance',
            'timestamp'         => '2013-04-03T23:44:21',
            'resource_metadata' => {},
            'source'            => 'artificial',
            'counter_unit'      => 'bytes',
            'counter_volume'    => 10.0,
            'project_id'        => 'd646b40dea6347dfb8caee2da1484c56',
            'message_id'        => '14e4a902-9cf3-11e2-a054-003048f5eafc',
            'counter_type'      => 'gauge'
          }]
          response
        end
      end
    end
  end
end
