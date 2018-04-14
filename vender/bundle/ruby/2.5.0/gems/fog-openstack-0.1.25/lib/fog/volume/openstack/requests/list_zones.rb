module Fog
  module Volume
    class OpenStack
      module Real
        def list_zones(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-availability-zone.json',
            :query   => options
          )
        end
      end

      module Mock
        def list_zones(_options = {})
          Excon::Response.new(
            :body   => {
              "availabilityZoneInfo" => [
                {
                  "zoneState" => {"available" => true},
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
