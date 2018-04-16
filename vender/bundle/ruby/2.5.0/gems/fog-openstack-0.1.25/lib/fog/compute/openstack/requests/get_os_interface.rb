module Fog
  module Compute
    class OpenStack
      class Real
        def get_os_interface(server_id,port_id)
          request(
            :expects => [200, 202, 203],
            :method  => 'GET',
            :path    => "servers/#{server_id}/os-interface/#{port_id}"
          )
        end
      end

      class Mock
        def get_os_interface(server_id,port_id)
          Excon::Response.new(
            :body   => {'interfaceAttachment' => data[:os_interfaces].first},
            :status => 200
          )
        end
      end
    end
  end
end
