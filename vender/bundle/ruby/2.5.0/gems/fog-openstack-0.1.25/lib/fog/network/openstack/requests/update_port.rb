module Fog
  module Network
    class OpenStack
      class Real
        def update_port(port_id, options = {})
          data = {'port' => {}}

          vanilla_options = [:name, :fixed_ips, :admin_state_up, :device_owner,
                             :device_id, :security_groups, :allowed_address_pairs]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['port'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "ports/#{port_id}.json"
          )
        end
      end

      class Mock
        def update_port(port_id, options = {})
          response = Excon::Response.new
          if port = list_ports.body['ports'].find { |_| _['id'] == port_id }
            port['name']                  = options[:name]
            port['fixed_ips']             = options[:fixed_ips] || []
            port['admin_state_up']        = options[:admin_state_up]
            port['device_owner']          = options[:device_owner]
            port['device_id']             = options[:device_id]
            port['security_groups']       = options[:security_groups] || []
            port['allowed_address_pairs'] = options[:allowed_address_pairs] || []
            response.body = {'port' => port}
            response.status = 200
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
