module Fog
  module Compute
    class OpenStack
      class Real
        def list_hypervisors_detail(options = {})
          request(
            :expects => 200,
            :method  => 'GET',
            :path    => 'os-hypervisors/detail',
            :query   => options
          )
        end
      end

      class Mock
        def list_hypervisors_detail(_options = {})
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "hypervisors"       => [{
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
              "id"                   => 2,
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
            }],
            "hypervisors_links" => [
              {
                "href" => "http://openstack.example.com/v2.1/6f70656e737461636b20342065766572/hypervisors/detail?limit=1&marker=2",
                "rel"  => "next"
              }
            ]
          }
          response
        end
      end
    end
  end
end
