module Fog
  module Network
    class OpenStack
      class Real
        def create_subnet(network_id, cidr, ip_version, options = {})
          data = {
            'subnet' => {
              'network_id' => network_id,
              'cidr'       => cidr,
              'ip_version' => ip_version
            }
          }

          vanilla_options = [:name, :gateway_ip, :allocation_pools,
                             :dns_nameservers, :host_routes, :enable_dhcp,
                             :tenant_id]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['subnet'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'subnets'
          )
        end
      end

      class Mock
        def create_subnet(network_id, cidr, ip_version, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'               => Fog::Mock.random_numbers(6).to_s,
            'name'             => options[:name],
            'network_id'       => network_id,
            'cidr'             => cidr,
            'ip_version'       => ip_version,
            'gateway_ip'       => options[:gateway_ip],
            'allocation_pools' => options[:allocation_pools],
            'dns_nameservers'  => options[:dns_nameservers],
            'host_routes'      => options[:host_routes],
            'enable_dhcp'      => options[:enable_dhcp],
            'tenant_id'        => options[:tenant_id]
          }
          self.data[:subnets][data['id']] = data
          response.body = {'subnet' => data}
          response
        end
      end
    end
  end
end
