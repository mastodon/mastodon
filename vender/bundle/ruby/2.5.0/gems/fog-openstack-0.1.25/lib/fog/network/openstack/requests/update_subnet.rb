module Fog
  module Network
    class OpenStack
      class Real
        def update_subnet(subnet_id, options = {})
          data = {'subnet' => {}}

          vanilla_options = [:name, :gateway_ip, :allocation_pools,
                             :dns_nameservers, :host_routes, :enable_dhcp]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['subnet'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "subnets/#{subnet_id}"
          )
        end
      end

      class Mock
        def update_subnet(subnet_id, options = {})
          response = Excon::Response.new
          if subnet = list_subnets.body['subnets'].find { |_| _['id'] == subnet_id }
            subnet['name']              = options[:name]
            subnet['gateway_ip']        = options[:gateway_ip]
            subnet['dns_nameservers']   = options[:dns_nameservers]   || []
            subnet['host_routes']       = options[:host_routes]       || []
            subnet['allocation_pools']  = options[:allocation_pools]  || []
            subnet['enable_dhcp']       = options[:enable_dhcp]
            response.body = {'subnet' => subnet}
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
