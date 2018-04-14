module Fog
  module Metering
    class OpenStack
      class Real
        def get_event(message_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "events/#{message_id}"
          )
        end
      end

      class Mock
        def get_event(_message_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            'event_type' => 'compute.instance.create',
            'message_id' => 'd646b40dea6347dfb8caee2da1484c56',
          }
          response
        end
      end
    end
  end
end
