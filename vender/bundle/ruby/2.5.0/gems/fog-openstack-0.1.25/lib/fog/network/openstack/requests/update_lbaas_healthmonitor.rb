module Fog
  module Network
    class OpenStack
      class Real
        def update_lbaas_healthmonitor(healthmonitor_id, options = {})
          data = {'healthmonitor' => {}}

          vanilla_options = [:name, :delay, :timeout, :max_retries, :http_method, :url_path, :expected_codes, :admin_state_up]
          vanilla_options.select { |o| options.key?(o) }.each do |key|
            data['healthmonitor'][key] = options[key]
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "lbaas/healthmonitors/#{healthmonitor_id}"
          )
        end
      end

      class Mock
        def update_lbaas_healthmonitor(healthmonitor_id, options = {})
          response = Excon::Response.new
          if healthmonitor = list_lbaas_health_monitors.body['healthmonitors'].find { |_| _['id'] == healthmonitor_id }
            healthmonitor['delay']          = options[:delay]
            healthmonitor['timeout']        = options[:timeout]
            healthmonitor['max_retries']    = options[:max_retries]
            healthmonitor['http_method']    = options[:http_method]
            healthmonitor['url_path']       = options[:url_path]
            healthmonitor['expected_codes'] = options[:expected_codes]
            healthmonitor['admin_state_up'] = options[:admin_state_up]
            response.body = {'healthmonitor' => healthmonitor}
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
