module Fog
  module Monitoring
    class OpenStack
      class Real
        def get_alarm_counts(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "alarms/count",
            :query   => options
          )
        end
      end

      class Mock
        # def get_alarm_counts(options = {})
        #
        # end
      end
    end
  end
end
