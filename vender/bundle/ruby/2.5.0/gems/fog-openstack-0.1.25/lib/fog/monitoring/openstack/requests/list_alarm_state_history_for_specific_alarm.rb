module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_alarm_state_history_for_specific_alarm(id, options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "alarms/#{id}/state-history",
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
