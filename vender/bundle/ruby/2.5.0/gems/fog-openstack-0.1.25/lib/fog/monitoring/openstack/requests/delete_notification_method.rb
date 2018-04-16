module Fog
  module Monitoring
    class OpenStack
      class Real
        def delete_notification_method(id)
          request(
            :expects => [204],
            :method  => 'DELETE',
            :path    => "notification-methods/#{id}"
          )
        end
      end

      class Mock
      end
    end
  end
end
