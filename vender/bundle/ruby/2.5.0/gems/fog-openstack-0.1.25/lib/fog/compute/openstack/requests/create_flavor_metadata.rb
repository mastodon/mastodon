module Fog
  module Compute
    class OpenStack
      class Real
        def create_flavor_metadata(flavor_ref, metadata)
          data = {
            'extra_specs' => metadata
          }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'POST',
            :path    => "flavors/#{flavor_ref}/os-extra_specs"
          )
        end
      end

      class Mock
        def create_flavor_metadata(_flavor_ref, _metadata)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = {"extra_specs" => {
            "cpu_arch" => "x86_64"
          }}
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
