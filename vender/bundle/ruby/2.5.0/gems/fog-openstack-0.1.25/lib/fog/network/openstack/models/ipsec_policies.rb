require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/ipsec_policy'

module Fog
  module Network
    class OpenStack
      class IpsecPolicies < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::IpsecPolicy

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_ipsec_policies(filters), 'ipsecpolicies')
        end

        def get(ipsec_policy_id)
          if ipsec_policy = service.get_ipsec_policy(ipsec_policy_id).body['ipsecpolicy']
            new(ipsec_policy)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
