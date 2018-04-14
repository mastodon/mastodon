module Fog
  module Event
    class OpenStack
      class Real
        def list_events(options = [])
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
            :path    => 'events'
          )
        end
      end

      class Mock
        def list_events(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = [{
            'event_type' => 'compute.instance.create',
            'message_id' => 'd646b40dea6347dfb8caee2da1484c56',
          }]
          response
        end
      end
    end
  end
end
