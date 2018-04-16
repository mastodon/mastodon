module Fog
  module Compute
    class OpenStack
      class Real
        def get_flavor_metadata(flavor_ref)
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "flavors/#{flavor_ref}/os-extra_specs"
          )
        end
      end

      class Mock
        def get_flavor_metadata(_flavor_ref)
          response = Excon::Response.new
          response.status = 200
          response.body = {"extra_specs" => {
            "cpu_arch" => "x86_64"
          }}
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
