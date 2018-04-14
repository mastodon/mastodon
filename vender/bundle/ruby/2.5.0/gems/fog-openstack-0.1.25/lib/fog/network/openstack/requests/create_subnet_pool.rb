module Fog
  module Network
    class OpenStack
      class Real
        def create_subnet_pool(name, prefixes, options = {})
          data = {
            'subnetpool' => {
              'name'     => name,
              'prefixes' => prefixes
            }
          }

          vanilla_options = [:description, :address_scope_id, :shared,
                             :min_prefixlen, :max_prefixlen, :default_prefixlen]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['subnetpool'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'subnetpools'
          )
        end
      end

      class Mock
        def create_subnet_pool(name, prefixes, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'                => Fog::Mock.random_numbers(6).to_s,
            'name'              => name,
            'prefixes'          => prefixes,
            'description'       => options[:description],
            'min_prefixlen'     => options[:min_prefixlen] || 64,
            'max_prefixlen'     => options[:max_prefixlen] || 64,
            'default_prefixlen' => options[:default_prefixlen] || 64,
            'address_scope_id'  => options[:address_scope_id],
            'default_quota'     => options[:default_quota],
            'ip_version'        => options[:ip_version] || 4,
            'shared'            => options[:shared].nil? ? false : options[:shared],
            'is_default'        => options[:is_default].nil? ? false : options[:is_default],
            'created_at'        => Time.now.to_s,
            'updated_at'        => Time.now.to_s,
            'tenant_id'         => Fog::Mock.random_hex(8).to_s
          }
          self.data[:subnet_pools][data['id']] = data
          response.body = {'subnetpool' => data}
          response
        end
      end
    end
  end
end
