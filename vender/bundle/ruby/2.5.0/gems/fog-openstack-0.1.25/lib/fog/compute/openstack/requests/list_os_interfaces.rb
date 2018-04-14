module Fog
  module Compute
    class OpenStack
      class Real
        def list_os_interfaces(server_id)
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "servers/#{server_id}/os-interface"
          )
        end
      end

      class Mock
        def list_os_interfaces(server_id)
          Excon::Response.new(
            :body   => {'interfaceAttachments' => data[:os_interfaces]},
            :status => 200
          )
        end
      end
    end
  end
end
