module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def list_bays
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "bays/detail"
          )
        end
      end

      class Mock
        def list_bays
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "bays" => [
              {
                "status"             => "CREATE_COMPLETE",
                "uuid"               => "746e779a-751a-456b-a3e9-c883d734946f",
                "stack_id"           => "9c6f1169-7300-4d08-a444-d2be38758719",
                "created_at"         => "2016-08-29T06:51:31+00:00",
                "api_address"        => "https://172.24.4.6:6443",
                "discovery_url"      => "https://discovery.etcd.io/cbeb580da58915809d59ee69348a84f3",
                "updated_at"         => "2016-08-29T06:53:24+00:00",
                "master_count"       => 1,
                "coe_version"        => "v1.2.0",
                "baymodel_id"        => "0562d357-8641-4759-8fed-8173f02c9633",
                "master_addresses"   => ["172.24.4.6"],
                "node_count"         => 1,
                "node_addresses"     => ["172.24.4.13"],
                "status_reason"      => "Stack CREATE completed successfully",
                "bay_create_timeout" => 60,
                "name"               => "k8s",
                "links"              => [
                  {
                     "href" => "http://10.164.180.104:9511/v1/bays/746e779a-751a-456b-a3e9-c883d734946f",
                     "rel"  => "self"
                  },
                  {
                     "href" => "http://10.164.180.104:9511/bays/746e779a-751a-456b-a3e9-c883d734946f",
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
