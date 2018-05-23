module Fog
  module Network
    class OpenStack
      class Real
        def create_lb_health_monitor(type, delay, timeout, max_retries, options = {})
          data = {
            'health_monitor' => {
              'type'        => type,
              'delay'       => delay,
              'timeout'     => timeout,
              'max_retries' => max_retries
            }
          }

          vanilla_options = [:http_method, :url_path, :expected_codes, :admin_state_up, :tenant_id]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['health_monitor'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'lb/health_monitors'
          )
        end
      end

      class Mock
        def create_lb_health_monitor(type, delay, timeout, max_retries, options = {})
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
          }

          self.data[:lb_health_monitors][data['id']] = data
          response.body = {'health_monitor' => data}
          response
        end
      end
    end
  end
end
