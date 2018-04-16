require 'fog/openstack/models/collection'
require 'fog/container_infra/openstack/models/cluster'

module Fog
  module ContainerInfra
    class OpenStack
      class Clusters < Fog::OpenStack::Collection

        model Fog::ContainerInfra::OpenStack::Cluster

        def all
          load_response(service.list_clusters, "clusters")
        end

        def get(cluster_uuid_or_name)
          resource = service.get_cluster(cluster_uuid_or_name).body
          new(resource)
        rescue Fog::ContainerInfra::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
