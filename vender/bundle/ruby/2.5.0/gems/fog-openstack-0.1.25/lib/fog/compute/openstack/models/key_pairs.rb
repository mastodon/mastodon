require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/key_pair'

module Fog
  module Compute
    class OpenStack
      class KeyPairs < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::KeyPair

        def all(options = {})
          items = []
          service.list_key_pairs(options).body['keypairs'].each do |kp|
            items += kp.values
          end
          # TODO: convert to load_response?
          load(items)
        end

        def get(key_pair_name)
          if key_pair_name
            all.select { |kp| kp.name == key_pair_name }.first
          end
        rescue Fog::Compute::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
