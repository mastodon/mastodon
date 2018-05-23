require 'fog/openstack/models/collection'
require 'fog/dns/openstack/v2/models/zone'

module Fog
  module DNS
    class OpenStack
      class V2
        class Zones < Fog::OpenStack::Collection
          model Fog::DNS::OpenStack::V2::Zone

          def all(options = {})
            load_response(service.list_zones(options), 'zones')
          end

          def find_by_id(id, options = {})
            zone_hash = service.get_zone(id, options).body
            new(zone_hash.merge(:service => service))
          end

          alias get find_by_id

          def destroy(id, options = {})
            zone = find_by_id(id, options)
            zone.destroy
          end
        end
      end
    end
  end
end
