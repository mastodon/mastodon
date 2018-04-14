module Fog
  module Openstack
    class Planning
      class Real
        def delete_plan(plan_uuid)
          request(
            :expects => [204],
            :method  => 'DELETE',
            :path    => "plans/#{plan_uuid}"
          )
        end
      end # class Real

      class Mock
        def delete_plan(_plan_uuid)
          response = Excon::Response.new
          response.status = 204
          response
        end # def delete_plans
      end # class Mock
    end # class Planning
  end # module Openstack
end # module Fog
