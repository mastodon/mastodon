module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_l7policy(listener_id, action, options = {})
          data = {
            'l7policy' => {
              'listener_id'  => listener_id,
              'action'       => action
            }
          }

          vanilla_options = [:tenant_id, :name, :description, :redirect_pool_id, :redirect_url, :position]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['l7policy'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/l7policies'
          )
        end
      end

      class Mock
        def create_lbaas_l7policy(listener_id, action, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'              => Fog::Mock.random_numbers(6).to_s,
            'listener_id'     => listener_id,
            'action'          => action,
            'position'        => options[:position],
            'tenant_id'       => options[:tenant_id],
            'name'            => options[:name],
            'description'     => options[:description],
            'redirect_pool_id'   => options[:redirect_pool_id],
            'redirect_url'    => options[:redirect_url]
          }

          self.data[:lbaas_l7policies][data['id']] = data
          response.body = {'l7policy' => data}
          response
        end
      end
    end
  end
end
