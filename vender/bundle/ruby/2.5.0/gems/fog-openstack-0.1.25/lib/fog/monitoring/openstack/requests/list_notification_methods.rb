module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_notification_methods(options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "notification-methods",
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
