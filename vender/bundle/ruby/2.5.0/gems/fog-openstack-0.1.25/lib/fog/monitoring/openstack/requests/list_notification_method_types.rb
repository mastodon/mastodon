module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_notification_method_types
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "notification-methods/types"
          )
        end
      end

      class Mock
        # def list_notification_method_types
        #
        # end
      end
    end
  end
end
