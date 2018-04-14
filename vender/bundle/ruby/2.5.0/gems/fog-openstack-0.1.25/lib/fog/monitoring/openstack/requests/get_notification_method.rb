module Fog
  module Monitoring
    class OpenStack
      class Real
        def get_notification_method(id)
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "notification-methods/#{id}"
          )
        end
      end

      class Mock
      end
    end
  end
end
