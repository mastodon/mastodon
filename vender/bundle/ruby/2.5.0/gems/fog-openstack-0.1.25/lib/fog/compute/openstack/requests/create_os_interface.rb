module Fog
  module Compute
    class OpenStack
      class Real
        # === Parameters
        # * server_id <~String>
        # * options <~Hash>
        def create_os_interface(server_id, options={})
          body = {
            'interfaceAttachment' => {}
          }

          if options[:port_id]
            body['interfaceAttachment']['port_id'] = options[:port_id]
          elsif options[:net_id]
            body['interfaceAttachment']['net_id'] = options[:net_id]
          end

          if options[:ip_address]
            body['interfaceAttachment']['fixed_ips'] = {ip_address: options[:ip_address]}
          end

          request(
            :body    => Fog::JSON.encode(body),
            :expects => [200, 201, 202, 204],
            :method  => 'POST',
            :path    => "servers/#{server_id}/os-interface"
          )
        end
      end

      class Mock
        def create_os_interface(server_id, options={})
          Excon::Response.new(
            :body   => {'interfaceAttachment' => data[:os_interfaces].first},
            :status => 200
          )
        end
      end
    end
  end
end
