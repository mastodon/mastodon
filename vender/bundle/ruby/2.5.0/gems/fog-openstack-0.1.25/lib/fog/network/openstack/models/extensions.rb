require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/extension'

module Fog
  module Network
    class OpenStack
      class Extensions < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::Extension

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_extensions(filters), 'extensions')
        end

        def get(extension_id)
          if extension = service.get_extension(extension_id).body['extension']
            new(extension)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
