require 'fog/openstack/models/collection'
require 'fog/key_manager/openstack/models/container'

module Fog
  module KeyManager
    class OpenStack
      class Containers < Fog::OpenStack::Collection
        model Fog::KeyManager::OpenStack::Container

        def all(options = {})
          load_response(service.list_containers(options), 'containers')
        end

        def get(secret_ref)
          if secret = service.get_container(secret_ref).body
            new(secret)
          end
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

      end
    end
  end
end