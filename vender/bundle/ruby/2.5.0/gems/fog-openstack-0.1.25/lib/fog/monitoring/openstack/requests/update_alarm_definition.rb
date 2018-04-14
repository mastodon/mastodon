module Fog
  module Monitoring
    class OpenStack
      class Real
        def update_alarm_definition(id, alarm_definition)
          request(
            :expects => [200],
            :method  => 'PUT',
            :path    => "alarm-definitions/#{id}",
            :body    => Fog::JSON.encode(alarm_definition)
          )
        end
      end

      class Mock
      end
    end
  end
end
