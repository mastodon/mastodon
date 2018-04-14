require 'fog/openstack/models/collection'
require 'fog/key_manager/openstack/models/secret'

module Fog
  module KeyManager
    class OpenStack
      class Secrets < Fog::OpenStack::Collection
        model Fog::KeyManager::OpenStack::Secret

        def all(options = {})
          load_response(service.list_secrets(options), 'secrets')
        end

        def get(secret_ref)
          if secret = service.get_secret(secret_ref).body
            new(secret)
          end
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end

      end
    end
  end
end