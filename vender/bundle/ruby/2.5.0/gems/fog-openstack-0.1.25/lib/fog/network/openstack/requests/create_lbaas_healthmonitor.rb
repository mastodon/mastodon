module Fog
  module Network
    class OpenStack
      class Real
        def create_lbaas_healthmonitor(pool_id, type, delay, timeout, max_retries, options = {})
          data = {
            'healthmonitor' => {
              'pool_id'     => pool_id,
              'type'        => type,
              'delay'       => delay,
              'timeout'     => timeout,
              'max_retries' => max_retries
            }
          }

          vanilla_options = [:http_method, :url_path, :expected_codes, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['healthmonitor'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lbaas/healthmonitors'
          )
        end
      end

      class Mock
        def create_lbaas_healthmonitor(type, delay, timeout, max_retries, options = {})
          response = Excon::Response.new
          response.status = 201
          data = {
            'id'             => Fog::Mock.random_numbers(6).to_s,
            'type'           => type,
            'delay'          => delay,
            'timeout'        => timeout,
            'max_retries'    => max_retries,
            'http_method'    => options[:http_method],
            'url_path'       => options[:url_path],
            'expected_codes' => options[:expected_codes],
            'status'         => 'ACTIVE',
            'admin_state_up' => options[:admin_state_up],
            'tenant_id'      => options[:tenant_id],
            'name'           => options[:name],
            'pools'          => [{ 'id'=> Fog::Mock.random_numbers(6).to_s}]
          }

          self.data[:lbaas_healthmonitors][data['id']] = data
          response.body = {'healthmonitor' => data}
          response
        end
      end
    end
  end
end
