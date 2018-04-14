module Fog
  module Network
    class OpenStack
      class Real
        def update_lb_vip(vip_id, options = {})
          data = {'vip' => {}}

          vanilla_options = [:pool_id, :name, :description, :session_persistence, :connection_limit, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['vip'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lb/vips/#{vip_id}"
          )
        end
      end

      class Mock
        def update_lb_vip(vip_id, options = {})
          response = Excon::Response.new
          if vip = list_lb_vips.body['vips'].find { |_| _['id'] == vip_id }
            vip['pool_id']             = options[:pool_id]
            vip['name']                = options[:name]
            vip['description']         = options[:description]
            vip['session_persistence'] = options[:session_persistence]
            vip['connection_limit']    = options[:connection_limit]
            vip['admin_state_up']      = options[:admin_state_up]
            response.body = {'vip' => vip}
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
