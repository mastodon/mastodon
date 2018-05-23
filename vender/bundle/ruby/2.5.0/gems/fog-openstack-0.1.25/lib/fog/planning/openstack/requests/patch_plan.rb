module Fog
  module Openstack
    class Planning
      class Real
        def patch_plan(plan_uuid, parameters)
          request(
            :expects => [201],
            :method  => 'PATCH',
            :path    => "plans/#{plan_uuid}",
            :body    => Fog::JSON.encode(parameters)
          )
        end
      end # class Real

      class Mock
        def patch_plan(_plan_uuid, _parameters)
          response = Excon::Response.new
          response.status = 201
          response.body = {
            "created_at"  => "2014-09-26T20:23:14.222815",
            "description" => "Development testing cloud",
            "name"        => "dev-cloud",
            "parameters"  =>
                             [
                               {
                                 "default"     => "guest",
                                 "description" => "The password for RabbitMQ",
                                 "hidden"      => true,
                                 "label"       => nil,
                                 "name"        => "compute-1::RabbitPassword",
                                 "value"       => "secret-password"
                               }
                             ],
            "roles"       =>
                             [
                               {
                                 "description" => "OpenStack hypervisor node. Can be wrapped in a ResourceGroup for scaling.\n",
                                 "name"        => "compute",
                                 "uuid"        => "b7b1583c-5c80-481f-a25b-708ed4a39734",
                                 "version"     => 1
                               }
                             ],
            "updated_at"  => nil,
            "uuid"        => "53268a27-afc8-4b21-839f-90227dd7a001"
          }
          response
        end # def patch_plans
      end # class Mock
    end # class Planning
  end # module Openstack
end # module Fog
