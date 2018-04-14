module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_alarm_state_history_for_all_alarms(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "alarms/state-history",
            :query   => options
          )
        end
      end

      class Mock
        # def list_alarm_state_history(options = {})
        #
        # end
      end
    end
  end
end
