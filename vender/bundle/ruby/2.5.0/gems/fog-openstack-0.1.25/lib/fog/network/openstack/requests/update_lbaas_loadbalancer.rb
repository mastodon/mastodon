module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_loadbalancer(loadbalancer_id, options = {})
          data = {
              'loadbalancer' => {}
          }

          vanilla_options = [:name, :description, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['loadbalancer'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/loadbalancers/#{loadbalancer_id}"
          )
        end
      end

      class Mock
        def update_lbaas_loadbalancer(loadbalancer_id, options = {})
          response = Excon::Response.new
          if loadbalancer = list_lbaas_loadbalancers.body['loadbalancers'].find { |_| _['id'] == loadbalancer_id }
            loadbalancer['name']                = options[:name]
            loadbalancer['description']         = options[:description]
            loadbalancer['admin_state_up']      = options[:admin_state_up]
            response.body = {'loadbalancer' => loadbalancer}
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
