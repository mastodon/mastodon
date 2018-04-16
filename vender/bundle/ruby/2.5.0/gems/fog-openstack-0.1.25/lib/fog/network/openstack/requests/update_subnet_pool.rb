module Fog
  module Network
    class OpenStack
      class Real
        def update_subnet_pool(subnet_pool_id, options = {})
          data = {'subnetpool' => {}}

          vanilla_options = [:name, :description, :prefixes, :address_scope_id,
                             :min_prefixlen, :max_prefixlen, :default_prefixlen]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['subnetpool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "subnetpools/#{subnet_pool_id}"
          )
        end
      end

      class Mock
        def update_subnet_pool(subnet_pool_id, options = {})
          subnet_pool = list_subnet_pools.body['subnetpools'].find { |s| s['id'] == subnet_pool_id }
          if subnet_pool
            subnet_pool['name']              = options[:name]
            subnet_pool['description']       = options[:description]
            subnet_pool['prefixes']          = options[:prefixes] || []
            subnet_pool['min_prefixlen']     = options[:min_prefixlen] || 64
            subnet_pool['max_prefixlen']     = options[:max_prefixlen] || 64
            subnet_pool['default_prefixlen'] = options[:default_prefixlen] || 64
            subnet_pool['address_scope_id']  = options[:address_scope_id]
            subnet_pool['updated_at']        = Time.now.to_s
            response = Excon::Response.new
            response.body = {'subnetpool' => subnet_pool}
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
