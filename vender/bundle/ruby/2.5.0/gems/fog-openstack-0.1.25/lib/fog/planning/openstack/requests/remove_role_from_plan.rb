module Fog
  module Openstack
    class Planning
      class Real
        def remove_role_from_plan(plan_uuid, role_uuid)
          request(
            :expects => [200],
            :method  => 'DELETE',
            :path    => "plans/#{plan_uuid}/roles/#{role_uuid}"
          )
        end
      end # class Real

      class Mock
        def remove_role_from_plan(_plan_uuid, _role_uuid)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "created_at"  => "2014-09-26T20:23:14.222815",
            "description" => "Development testing cloud",
            "name"        => "dev-cloud",
            "parameters"  => [],
            "roles"       => [],
            "updated_at"  => nil,
            "uuid"        => "53268a27-afc8-4b21-839f-90227dd7a001"
          }
          response
        end # def remove_role_from_plan
      end # class Mock
    end # class Planning
  end # module Openstack
end # module Fog
