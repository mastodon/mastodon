module Fog
  module Compute
    class OpenStack
      class Real
        def delete_service(uuid, optional_params = nil)
          # Encode all params
          optional_params = optional_params.each { |k, v| optional_params[k] = URI.encode(v) } if optional_params

          request(
            :expects => [202, 204],
            :method  => 'DELETE',
            :path    => "os-services/#{uuid}",
            :query   => optional_params
          )
        end
      end

      class Mock
        def delete_service(_host, _binary, _optional_params = nil)
          response = Excon::Response.new
          response.status = 204
          response.headers = {
            "Content-Type"   => "text/html; charset=UTF-8",
            "Content-Length" => "0",
            "Date"           => Date.new
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
