module Fog
  module Compute
    class OpenStack
      class Real
        # === Parameters
        # * server_id <~String>
        # * port_id <~String>
        def delete_os_interface(server_id, port_id)
          request(
            :expects => [200, 202,204],
            :method  => 'DELETE',
            :path    => "servers/#{server_id}/os-interface/#{port_id}"
          )
        end
      end

      class Mock
        def delete_os_interface(server_id, port_id)
          true
        end
      end
    end
  end
end
