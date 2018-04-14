module Fog
  module Baremetal
    class OpenStack
      class Real
        # Create a new chassis
        #
        # === Attributes ===
        # description  = Free text description of the chassis
        # extra        = Record arbitrary key/value metadata. Can be specified multiple times
        def create_chassis(attributes)
          desired_options = [
            :description,
            :extra
          ]

          # Filter only allowed creation attributes
          data = attributes.select { |key, _value| desired_options.include?(key.to_sym) }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 201],
            :method  => 'POST',
            :path    => 'chassis'
          )
        end
      end

      class Mock
        def create_chassis(_attributes)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = data[:chassis_collection].first
          response
        end
      end # mock
    end # openstack
  end # baremetal
end # fog
