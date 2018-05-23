module Fog
  module Compute
    class OpenStack
      class Real
        def disable_service_log_reason(host, binary, disabled_reason, optional_params = nil)
          data = {"host" => host, "binary" => binary, "disabled_reason" => disabled_reason}

          # Encode all params
          optional_params = optional_params.each { |k, v| optional_params[k] = URI.encode(v) } if optional_params

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "os-services/disable-log-reason",
            :query   => optional_params
          )
        end
      end

      class Mock
        def disable_service_log_reason(_host, _binary, _disabled_reason, _optional_params = nil)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "service" => {
              "host"            => "host1",
              "binary"          => "nova-compute",
              "status"          => "disabled",
              "disabled_reason" => "test2"
            }
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
