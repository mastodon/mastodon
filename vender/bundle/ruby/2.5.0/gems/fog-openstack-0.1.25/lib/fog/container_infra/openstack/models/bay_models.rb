require 'fog/openstack/models/collection'
require 'fog/container_infra/openstack/models/bay_model'

module Fog
  module ContainerInfra
    class OpenStack
      class BayModels < Fog::OpenStack::Collection
        model Fog::ContainerInfra::OpenStack::BayModel

        def all
          load_response(service.list_bay_models, 'baymodels')
        end

        def get(bay_model_uuid_or_name)
          resource = service.get_bay_model(bay_model_uuid_or_name).body
          new(resource)
        rescue Fog::ContainerInfra::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
