module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_loadbalancer(vip_subnet_id, options = {})
          data = {
              'loadbalancer' => {
                  'vip_subnet_id' => vip_subnet_id
              }
          }
          vanilla_options = [:name, :description, :vip_address, :provider, :flavor, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['loadbalancer'][key] = options[key]
          end

          request(
              :body => Fog::JSON.encode(data),
              :expects => [201],
              :method => 'POST',
              :path => 'lbaas/loadbalancers'
          )
        end
      end

      class Mock
        def create_lbaas_loadbalancer(vip_subnet_id, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
              'id' => Fog::Mock.random_numbers(6).to_s,
              'subnet_id' => vip_subnet_id,
              'name' => options[:name],
              'description' => options[:description],
              'vip_address' => options[:vip_address],
              'vip_port_id'=> Fog::Mock.random_numbers(6).to_s,
              'vip_subnet_id'=> vip_subnet_id,
              'flavor' => options[:flavor],
              'admin_state_up' => options[:admin_state_up],
              'tenant_id' => options[:tenant_id],
              'listeners'=> [{ 'id'=> Fog::Mock.random_numbers(6).to_s}],
              'operating_status'=> 'ONLINE',
              'provider'=> 'lbprovider',
              'provisioning_status'=> 'ACTIVE'
          }
          self.data[:lbaas_loadbalancer][data['id']] = data
          response.body = {'loadbalancer' => data}
          response
        end
      end
    end
  end
end
