module Fog
  module Network
    class OpenStack
      class Real
        def update_lb_health_monitor(health_monitor_id, options = {})
          data = {'health_monitor' => {}}

          vanilla_options = [:delay, :timeout, :max_retries, :http_method, :url_path, :expected_codes, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['health_monitor'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lb/health_monitors/#{health_monitor_id}"
          )
        end
      end

      class Mock
        def update_lb_health_monitor(health_monitor_id, options = {})
          response = Excon::Response.new
          if health_monitor = list_lb_health_monitors.body['health_monitors'].find { |_| _['id'] == health_monitor_id }
            health_monitor['delay']          = options[:delay]
            health_monitor['timeout']        = options[:timeout]
            health_monitor['max_retries']    = options[:max_retries]
            health_monitor['http_method']    = options[:http_method]
            health_monitor['url_path']       = options[:url_path]
            health_monitor['expected_codes'] = options[:expected_codes]
            health_monitor['admin_state_up'] = options[:admin_state_up]
            response.body = {'health_monitor' => health_monitor}
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
