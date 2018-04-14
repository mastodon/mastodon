module Fog
  module Compute
    class OpenStack
      class Real
        def list_zones_detailed(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-availability-zone/detail',
            :query   => options
          )
        end
      end

      class Mock
        def list_zones_detailed(_options = {})
          Excon::Response.new(
            :body   => {
              "availabilityZoneInfo" => [
                {
                  "zoneState" => {
                    "available" => true
                  },
                  "hosts"     => {
                    "instack.localdomain" => {
                      "nova-conductor"   => {
                        "available"  => true,
                        "active"     => true,
                        "updated_at" => "2015-07-22T07:40:08.000000"
                      },
                      "nova-scheduler"   => {
                        "available"  => true,
                        "active"     => true,
                        "updated_at" => "2015-07-22T07:40:04.000000"
                      },
                      "nova-consoleauth" => {
                        "available"  => true,
                        "active"     => true,
                        "updated_at" => "2015-07-22T07:40:09.000000"
                      }
                    }
                  },
                  "zoneName"  => "internal"
                },
                {
                  "zoneState" => {
                    "available" => true
                  },
                  "hosts"     => {
                    "instack.localdomain" => {
                      "nova-compute" => {
                        "available"  => true,
                        "active"     => true,
                        "updated_at" => "2015-07-22T07:40:04.000000"
                      }
                    }
                  },
                  "zoneName"  => "nova"
                }
              ]
            },
            :status => 200
          )
        end
      end
    end
  end
end
