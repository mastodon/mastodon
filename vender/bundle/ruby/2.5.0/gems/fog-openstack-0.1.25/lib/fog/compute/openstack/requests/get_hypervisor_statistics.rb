module Fog
  module Compute
    class OpenStack
      class Real
        def get_hypervisor_statistics(_tenant_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "os-hypervisors/statistics"
          )
        end
      end

      class Mock
        def get_hypervisor_statistics(_tenant_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "hypervisor_statistics" => {
              "count"                => 1,
              "current_workload"     => 0,
              "disk_available_least" => 0,
              "free_disk_gb"         => 1028,
              "free_ram_mb"          => 7680,
              "local_gb"             => 1028,
              "local_gb_used"        => 0,
              "memory_mb"            => 8192,
              "memory_mb_used"       => 512,
              "running_vms"          => 0,
              "vcpus"                => 1,
              "vcpus_used"           => 0
            }
          }
          response
        end
      end
    end
  end
end
