require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v3/models/policy'

module Fog
  module Identity
    class OpenStack
      class V3
        class Policies < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V3::Policy

          def all(options = {})
            load_response(service.list_policies(options), 'policies')
          end

          def find_by_id(id)
            cached_policy = find { |policy| policy.id == id }
            return cached_policy if cached_policy
            policy_hash = service.get_policy(id).body['policy']
            Fog::Identity::OpenStack::V3::Policy.new(
              policy_hash.merge(:service => service)
            )
          end

          def destroy(id)
            policy = find_by_id(id)
            policy.destroy
          end
        end
      end
    end
  end
end
