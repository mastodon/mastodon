module Fog
  module Baremetal
    class OpenStack
      class Real
        # Patch a port
        #
        # parameter example:
        # [{:op=> 'replace', :path => "/driver_info/ipmi_address", :value => "192.0.2.1"}]
        #
        # === Patch parameter, list of jsonpatch ===
        # op    =  Operations: 'add', 'replace' or 'remove'
        # path  =  Attributes to add/replace or remove (only PATH is necessary on remove),
        #          e.g. /driver_info/ipmi_address
        # value = Value to set
        def patch_port(port_uuid, patch)
          request(
            :body    => Fog::JSON.encode(patch),
            :expects => 200,
            :method  => 'PATCH',
            :path    => "ports/#{port_uuid}"
          )
        end
      end

      class Mock
        def patch_port(_port_uuid, _patch)
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
