module Fog
  module Compute
    class OpenStack
      class Real
        def update_flavor_metadata(flavor_ref, key, value)
          data = {key => value}

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'PUT',
            :path    => "flavors/#{flavor_ref}/os-extra_specs/#{key}"
          )
        end
      end

      class Mock
        def update_flavor_metadata(_flavor_ref, key, value)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = {key => value}
          response
        end
      end
    end
  end
end
