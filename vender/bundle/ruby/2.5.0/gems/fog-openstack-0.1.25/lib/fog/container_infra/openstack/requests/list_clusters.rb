module Fog
  module ContainerInfra
    class OpenStack
      class Real
        def list_clusters
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "clusters/detail"
          )
        end
      end

      class Mock
        def list_clusters
          response = Excon::Response.new
          response.status = 200
          response.body = {
            "clusters" => [
              {
                "status"              => "CREATE_IN_PROGRESS",
                "cluster_template_id" => "0562d357-8641-4759-8fed-8173f02c9633",
                "uuid"                => "731387cf-a92b-4c36-981e-3271d63e5597",
                "stack_id"            => "31c1ee6c-081e-4f39-9f0f-f1d87a7defa1",
                "master_count"        => 1,
                "create_timeout"      => 60,
                "node_count"          => 1,
                "name"                => "k8s"
              }
            ]
          }
          response
        end
      end
    end
  end
end
