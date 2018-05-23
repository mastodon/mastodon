module Fog
  module Monitoring
    class OpenStack
      class Real
        def create_alarm_definition(options)
          request(
            :body    => Fog::JSON.encode(options),
            :expects => [201, 204],
            :method  => 'POST',
            :path    => 'alarm-definitions'
          )
        end
      end

      class Mock
      end
    end
  end
end
