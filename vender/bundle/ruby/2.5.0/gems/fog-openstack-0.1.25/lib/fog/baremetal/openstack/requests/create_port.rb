module Fog
  module Baremetal
    class OpenStack
      class Real
        # Create a new port
        #
        # === Attributes ===
        # address   = MAC Address for this port
        # extra     = Record arbitrary key/value metadata. Can be specified multiple times
        # node_uuid = UUID of the node that this port belongs to
        def create_port(attributes)
          desired_options = [
            :address,
            :extra,
            :node_uuid
          ]

          # Filter only allowed creation attributes
          data = attributes.select { |key, _value| desired_options.include?(key.to_sym) }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 201],
            :method  => 'POST',
            :path    => 'ports'
          )
        end
      end

      class Mock
        def create_port(_attributes)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = data[:ports].first
          response
        end
      end # mock
    end # openstack
  end # baremetal
end # fog
