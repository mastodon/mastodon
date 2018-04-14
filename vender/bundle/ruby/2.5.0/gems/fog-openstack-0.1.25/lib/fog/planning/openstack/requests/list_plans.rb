module Fog
  module Openstack
    class Planning
      class Real
        def list_plans(options = {})
          request(
            :expects => [200, 204],
            :method  => 'GET',
            :path    => 'plans',
            :query   => options
          )
        end
      end # class Real

      class Mock
        def list_plans(_options = {})
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = [
            {
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
                                   "name"        => "compute-1 => =>RabbitPassword",
                                   "value"       => "secret-password"
                                 },
                                 {
                                   "default"     => "default",
                                   "description" => "description",
                                   "hidden"      => true,
                                   "label"       => nil,
                                   "name"        => "name",
                                   "value"       => "value"
                                 },
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
          ]
          response
        end # def list_plans
      end # class Mock
    end # class Planning
  end # module Openstack
end # module Fog
