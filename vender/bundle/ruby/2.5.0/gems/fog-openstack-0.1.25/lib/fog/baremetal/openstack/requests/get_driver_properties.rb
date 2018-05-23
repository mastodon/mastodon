module Fog
  module Baremetal
    class OpenStack
      class Real
        def get_driver_properties(driver_name)
          data = {:driver_name => driver_name}
          request(
            :body    => Fog::JSON.encode(data),
            :expects => [200, 204],
            :method  => 'GET',
            :path    => "drivers/properties"
          )
        end
      end # class Real

      class Mock
        def get_driver_properties(_driver_name)
          response = Excon::Response.new
          response.status = [200, 204][rand(2)]
          response.body = {
            "pxe_deploy_ramdisk"   => "UUID (from Glance) of the ramdisk.",
            "ipmi_transit_address" => "transit address for bridged request.",
            "ipmi_terminal_port"   => "node's UDP port to connect to.",
            "ipmi_target_channel"  => "destination channel for bridged request.",
            "ipmi_transit_channel" => "transit channel for bridged request.",
            "ipmi_local_address"   => "local IPMB address for bridged requests. ",
            "ipmi_username"        => "username; default is NULL user. Optional.",
            "ipmi_address"         => "IP address or hostname of the node. Required.",
            "ipmi_target_address"  => "destination address for bridged request.",
            "ipmi_password"        => "password. Optional.",
            "pxe_deploy_kernel"    => "UUID (from Glance) of the deployment kernel.",
            "ipmi_priv_level"      => "privilege level; default is ADMINISTRATOR. ",
            "ipmi_bridging"        => "bridging_type."
          }
          response
        end # def get_driver_properties
      end # class Mock
    end # class OpenStack
  end # module Baremetal
end # module Fog
