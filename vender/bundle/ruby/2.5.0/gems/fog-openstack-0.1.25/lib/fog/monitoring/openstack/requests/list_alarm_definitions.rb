module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_alarm_definitions(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "alarm-definitions",
            :query   => options
          )
        end
      end

      class Mock
        # def list_metrics(options = {})
        #
        # end
      end
    end
  end
end
