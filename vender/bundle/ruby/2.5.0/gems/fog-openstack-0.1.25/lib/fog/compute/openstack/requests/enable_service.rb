module Fog
  module Compute
    class OpenStack
      class Real
        def enable_service(host, binary, optional_params = nil)
          data = {"host" => host, "binary" => binary}

          # Encode all params
          optional_params = optional_params.each { |k, v| optional_params[k] = URI.encode(v) } if optional_params

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "os-services/enable",
            :query   => optional_params
          )
        end
      end

      class Mock
        def enable_service(_host, _binary, _optional_params = nil)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "service" => {
              "host"   => "host1",
              "binary" => "nova-compute",
              "status" => "enabled"
            }
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
