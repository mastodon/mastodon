require 'fog/openstack/models/collection'
require 'fog/container_infra/openstack/models/cluster_template'

module Fog
  module ContainerInfra
    class OpenStack
      class ClusterTemplates < Fog::OpenStack::Collection

        model Fog::ContainerInfra::OpenStack::ClusterTemplate

        def all
          load_response(service.list_cluster_templates, 'clustertemplates')
        end

        def get(cluster_template_uuid_or_name)
          resource = service.get_cluster_template(cluster_template_uuid_or_name).body
          new(resource)
        rescue Fog::ContainerInfra::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
