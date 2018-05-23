module Fog
  module Compute
    class OpenStack
      class Real
        def list_services(parameters = nil)
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'os-services',
            :query   => parameters
          )
        end
      end

      class Mock
        def list_services(_parameters = nil)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "services" => [{
              "id"              => 1,
              "binary"          => "nova-scheduler",
              "host"            => "host1",
              "state"           => "up",
              "status"          => "disabled",
              "updated_at"      => "2012-10-29T13:42:02.000000",
              "zone"            => "internal",
              "disabled_reason" => "test2"
            },
                           {
                             "id"              => 2,
                             "binary"          => "nova-compute",
                             "host"            => "host1",
                             "state"           => "up",
                             "status"          => "disabled",
                             "updated_at"      => "2012-10-29T13:42:05.000000",
                             "zone"            => "nova",
                             "disabled_reason" => "test2"
                           },
                           {
                             "id"              => 3,
                             "binary"          => "nova-scheduler",
                             "host"            => "host2",
                             "state"           => "down",
                             "status"          => "enabled",
                             "updated_at"      => "2012-09-19T06:55:34.000000",
                             "zone"            => "internal",
                             "disabled_reason" => "nil"
                           },
                           {
                             "id"              => 4,
                             "binary"          => "nova-compute",
                             "host"            => "host2",
                             "state"           => "down",
                             "status"          => "disabled",
                             "updated_at"      => "2012-09-18T08:03:38.000000",
                             "zone"            => "nova",
                             "disabled_reason" => "test2"
                           }]
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
