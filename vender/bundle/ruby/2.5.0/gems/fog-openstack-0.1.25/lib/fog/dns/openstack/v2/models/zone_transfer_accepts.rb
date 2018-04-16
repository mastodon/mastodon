require 'fog/openstack/models/collection'
require 'fog/dns/openstack/v2/models/zone_transfer_accept'

module Fog
  module DNS
    class OpenStack
      class V2
        class ZoneTransferAccepts < Fog::OpenStack::Collection
          model Fog::DNS::OpenStack::V2::ZoneTransferAccept

          def all(options = {})
            load_response(service.list_zone_transfer_accepts(options), 'transfer_accepts')
          end

          def find_by_id(id)
            zone_transfer_accept_hash = service.get_zone_transfer_accept(id).body
            new(zone_transfer_accept_hash.merge(:service => service))
          end

          alias get find_by_id
        end
      end
    end
  end
end
