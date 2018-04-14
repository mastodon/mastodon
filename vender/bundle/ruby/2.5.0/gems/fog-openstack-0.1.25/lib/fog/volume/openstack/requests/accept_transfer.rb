module Fog
  module Volume
    class OpenStack
      module Real
        def accept_transfer(transfer_id, auth_key)
          data = {
            'accept' => {
              'auth_key' => auth_key
            }
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 202],
            :method  => 'POST',
            :path    => "os-volume-transfer/#{transfer_id}/accept"
          )
        end
      end
    end
  end
end
