module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def list_bay_models
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "baymodels/detail"
          )
        end
      end

      class Mock
        def list_bay_models
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "baymodels" => [
              {
                "insecure_registry"     => nil,
                "http_proxy"            => "http://10.164.177.169:8080",
                "updated_at"            => nil,
                "floating_ip_enabled"   => true,
                "fixed_subnet"          => nil,
                "master_flavor_id"      => nil,
                "uuid"                  => "085e1c4d-4f68-4bfd-8462-74b9e14e4f39",
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
                "name"                  => "k8s-bm2",
                "created_at"            => "2016-08-29T02:08:08+00:00",
                "network_driver"        => "flannel",
                "fixed_network"         => nil,
                "coe"                   => "kubernetes",
                "flavor_id"             => "m1.small",
                "master_lb_enabled"     => true,
                "dns_nameserver"        => "8.8.8.8",
                "links" => [
                  {
                     "href" => "http://10.164.180.104:9511/v1/baymodels/085e1c4d-4f68-4bfd-8462-74b9e14e4f39",
                     "rel"  => "self"
                  },
                  {
                     "href" => "http://10.164.180.104:9511/baymodels/085e1c4d-4f68-4bfd-8462-74b9e14e4f39",
                     "rel"  => "bookmark"
                  }
                ]
              }
            ]
          }
          response
        end
      end
    end
  end
end
