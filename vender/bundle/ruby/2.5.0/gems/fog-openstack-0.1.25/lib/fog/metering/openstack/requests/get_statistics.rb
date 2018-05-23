module Fog
  module Metering
    class OpenStack
      class Real
        def get_statistics(meter_id, options = {})
          data = {
            'period' => options['period'],
            'q'      => []
          }

          options['q'].each do |opt|
            filter = {}

            ['field', 'op', 'value'].each do |key|
              filter[key] = opt[key] if opt[key]
            end

            data['q'] << filter unless filter.empty?
          end if options['q'].kind_of? Array

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'GET',
            :path    => "meters/#{meter_id}/statistics"
          )
        end
      end

      class Mock
        def get_statistics(_meter_id, _options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [{
            'count'          => 143,
            'duration_start' => '2013-04-03T23:44:21',
            'min'            => 10.0,
            'max'            => 10.0,
            'duration_end'   => '2013-04-04T23:24:21',
            'period'         => 0,
            'period_end'     => '2013-04-04T23:24:21',
            'duration'       => 85200.0,
            'period_start'   => '2013-04-03T23:44:21',
            'avg'            => 10.0,
            'sum'            => 1430.0
          }]
          response
        end
      end
    end
  end
end
