module Fog
  module Openstack
    class Planning
      class Real
        def create_plan(parameters)
          request(
            :expects => [201],
            :method  => 'POST',
            :path    => "plans",
            :body    => Fog::JSON.encode(parameters)
          )
        end
      end # class Real

      class Mock
        def create_plan(_parameters)
          response = Excon::Response.new
          response.status = 201
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
        end # def create_plans
      end # class Mock
    end # class Planning
  end # module Openstack
end # module Fog
