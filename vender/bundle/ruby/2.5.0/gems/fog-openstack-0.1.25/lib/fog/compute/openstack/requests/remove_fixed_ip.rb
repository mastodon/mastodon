module Fog
  module Compute
    class OpenStack
      class Real
        # Remove an IP address.
        #
        # === Parameters
        # * server_id <~String> - The ID of the server in which to remove an IP from.
        # * address <~String> - The IP address to be removed.
        # === Returns
        # * success <~Boolean>
        def remove_fixed_ip(server_id, address)
          body = {
            'removeFixedIp' => {
              'address' => address
            }
          }
          server_action(server_id, body).status == 202
        end # def remove_fixed_ip
      end # class Real

      class Mock
        def remove_fixed_ip(_server_id, _address)
          true
        end # def remove_fixed_ip
      end # class Mock
    end # class OpenStack
  end # module Compute
end # module Fog
