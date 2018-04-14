require 'fog/openstack/models/collection'

module Fog
  module Volume
    class OpenStack
      module Transfers
        def all(options = {})
          load_response(service.list_transfers_detailed(options), 'transfers')
        end

        def summary(options = {})
          load_response(service.list_transfers(options), 'transfers')
        end

        def get(transfer_id)
          if transfer = service.get_transfer_details(transfer_id).body['transfer']
            new(transfer)
          end
        rescue Fog::Volume::OpenStack::NotFound
          nil
        end

        def accept(transfer_id, auth_key)
          # NOTE: This is NOT a method on the Transfer object, since the
          # receiver cannot see the transfer object in the get_transfer_details
          # or list_transfers(_detailed) requests.
          if transfer = service.accept_transfer(transfer_id, auth_key).body['transfer']
            new(transfer)
          end
        end
      end
    end
  end
end
