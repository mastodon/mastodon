module Fog
  module Compute
    class OpenStack
      class Real
        def get_host_details(host)
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "os-hosts/#{host}"
          )
        end
      end

      class Mock
        def get_host_details(_host)
          response = Excon::Response.new
          response.status = 200
          response.body = {"host" => [
            {"resource" => {
              "project"   => "(total)",
              "memory_mb" => 64427,
              "host"      => "cn28.la-1-3.morphcloud.net",
              "cpu"       => 12,
              "disk_gb"   => 1608
            }},
            {"resource" => {
              "project"   => "(used_now)",
              "memory_mb" => 1753,
              "host"      => "cn28.la-1-3.morphcloud.net",
              "cpu"       => 3,
              "disk_gb"   => 33
            }},
            {"resource" => {
              "project"   => "(used_max)",
              "memory_mb" => 7168,
              "host"      => "cn28.la-1-3.morphcloud.net",
              "cpu"       => 3,
              "disk_gb"   => 45
            }},
            {"resource" => {
              "project"   => "bf8301f5164f4790889a1bc2bfb16d99",
              "memory_mb" => 5120,
              "host"      => "cn28.la-1-3.morphcloud.net",
              "cpu"       => 2,
              "disk_gb"   => 35
            }},
            {"resource" => {
              "project"   => "3bb4d0301c5f47d5b4d96a361fcf96f4",
              "memory_mb" => 2048,
              "host"      => "cn28.la-1-3.morphcloud.net",
              "cpu"       => 1,
              "disk_gb"   => 10
            }}
          ]}
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
