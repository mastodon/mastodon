module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def list_cluster_templates
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "clustertemplates/detail"
          )
        end
      end

      class Mock
        def list_cluster_templates
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "clustertemplates" => [
              {
                "insecure_registry"     => nil,
                "http_proxy"            => "http://10.164.177.169:8080",
                "updated_at"            => nil,
                "floating_ip_enabled"   => true,
                "fixed_subnet"          => nil,
                "master_flavor_id"      => nil,
                "uuid"                  => "0562d357-8641-4759-8fed-8173f02c9633",
                "no_proxy"              => "10.0.0.0/8,172.0.0.0/8,192.0.0.0/8,localhost",
                "https_proxy"           => "http://10.164.177.169:8080",
                "tls_disabled"          => false,
                "keypair_id"            => "kp",
                "public"                => false,
                "labels"                => {},
                "docker_volume_size"    => 3,
                "server_type"           => "vm",
                "external_network_id"   => "public",
                "cluster_distro"        => "fedora-atomic",
                "image_id"              => "fedora-atomic-latest",
                "volume_driver"         => "cinder",
                "registry_enabled"      => false,
                "docker_storage_driver" => "devicemapper",
                "apiserver_port"        => nil,
                "name"                  => "k8s-bm",
                "created_at"            => "2016-08-26T09:34:41+00:00",
                "network_driver"        => "flannel",
                "fixed_network"         => nil,
                "coe"                   => "kubernetes",
                "flavor_id"             => "m1.small",
                "master_lb_enabled"     => false,
                "dns_nameserver"        => "8.8.8.8"
              }
            ]
          }
          response
        end
      end
    end
  end
end
