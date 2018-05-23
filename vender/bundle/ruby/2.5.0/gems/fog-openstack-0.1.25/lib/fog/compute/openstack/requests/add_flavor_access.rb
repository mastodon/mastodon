module Fog
  module Compute
    class OpenStack
      class Real
        def add_flavor_access(flavor_ref, tenant_id)
          request(
            :body    => Fog::JSON.encode("addTenantAccess" => {
                                           "tenant" => tenant_id
                                         }),
            :expects => [200, 203],
            :method  => 'POST',
            :path    => "flavors/#{flavor_ref}/action"
          )
        end
      end

      class Mock
        def add_flavor_access(flavor_ref, tenant_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "flavor_access" => [{"tenant_id" => tenant_id.to_s, "flavor_id" => flavor_ref.to_s}]
          }
          response
        end
      end
    end
  end
end
