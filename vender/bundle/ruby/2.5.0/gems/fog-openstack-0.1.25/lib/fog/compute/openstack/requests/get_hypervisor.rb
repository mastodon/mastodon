module Fog
  module Compute
    class OpenStack
      class Real
        def get_hypervisor(hypervisor_id)
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => "os-hypervisors/#{hypervisor_id}"
          )
        end
      end

      class Mock
        def get_hypervisor(hypervisor_id)
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "hypervisor" => {
              "cpu_info"             => {
                "arch"     => "x86_64",
                "model"    => "Nehalem",
                "vendor"   => "Intel",
                "features" => [
                  "pge",
                  "clflush"
                ],
                "topology" => {
                  "cores"   => 1,
                  "threads" => 1,
                  "sockets" => 4
                }
              },
              "current_workload"     => 0,
              "status"               => "enabled",
              "state"                => "up",
              "disk_available_least" => 0,
              "host_ip"              => "1.1.1.1",
              "free_disk_gb"         => 1028,
              "free_ram_mb"          => 7680,
              "hypervisor_hostname"  => "fake-mini",
              "hypervisor_type"      => "fake",
              "hypervisor_version"   => 1000,
              "id"                   => hypervisor_id,
              "local_gb"             => 1028,
              "local_gb_used"        => 0,
              "memory_mb"            => 8192,
              "memory_mb_used"       => 512,
              "running_vms"          => 0,
              "service"              => {
                "host"            => "host1",
                "id"              => 7,
                "disabled_reason" => null
              },
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
