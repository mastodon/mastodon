require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/ike_policy'

module Fog
  module Network
    class OpenStack
      class IkePolicies < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::IkePolicy

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_ike_policies(filters), 'ikepolicies')
        end

        def get(ike_policy_id)
          if ike_policy = service.get_ike_policy(ike_policy_id).body['ikepolicy']
            new(ike_policy)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
