module Fog
  module Monitoring
    class OpenStack
      class Real
        def put_notification_method(id, notification)
          request(
            :expects => [200],
            :method  => 'PUT',
            :path    => "notification-methods/#{id}",
            :body    => Fog::JSON.encode(notification)
          )
        end
      end

      class Mock
      end
    end
  end
end
