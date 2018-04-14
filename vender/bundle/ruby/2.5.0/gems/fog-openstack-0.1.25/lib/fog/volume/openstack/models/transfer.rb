require 'fog/openstack/models/model'

module Fog
  module Volume
    class OpenStack
      class Transfer < Fog::OpenStack::Model
        def save
          requires :name, :volume_id
          data = service.create_transfer(volume_id, :name => name)
          merge_attributes(data.body['transfer'])
          true
        end

        def destroy
          requires :id
          service.delete_transfer(id)
          true
        end

        def initialize(attributes)
          # Old 'connection' is renamed as service and should be used instead
          prepare_service_value(attributes)
          super
        end
      end
    end
  end
end
