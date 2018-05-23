module Fog
  module Baremetal
    class OpenStack
      class Real
        # Create a new node
        #
        # === Attributes ===
        # chassis_uuid = UUID of the chassis that this node belongs to
        # driver       = Driver used to control the node [REQUIRED]
        # driver_info  = Key/value pairs used by the driver, such as out-of-band management credentials. Can be
        #                specified multiple times
        # extra        = Record arbitrary key/value metadata. Can be specified multiple times
        # uuid         = Unique UUID for the node
        # properties   = Key/value pairs describing the physical characteristics of the node. This is exported to
        #                Nova and used by the scheduler. Can be specified multiple times
        def create_node(attributes)
          desired_options = [
            :chassis_uuid,
            :driver,
            :driver_info,
            :extra,
            :uuid,
            :properties
          ]

          # Filter only allowed creation attributes
          data = attributes.select { |key, _value| desired_options.include?(key.to_sym) }

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 201],
            :method  => 'POST',
            :path    => 'nodes'
          )
        end
      end

      class Mock
        def create_node(_attributes)
          response = Excon::Response.new
          response.status = 200
          response.headers = {
            "X-Compute-Request-Id" => "req-fdc6f99e-55a2-4ab1-8904-0892753828cf",
            "Content-Type"         => "application/json",
            "Content-Length"       => "356",
            "Date"                 => Date.new
          }
          response.body = data[:nodes].first
          response
        end
      end # mock
    end # openstack
  end # baremetal
end # fog
