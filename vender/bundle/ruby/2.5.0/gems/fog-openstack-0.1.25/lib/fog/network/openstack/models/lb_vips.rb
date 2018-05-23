require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/lb_vip'

module Fog
  module Network
    class OpenStack
      class LbVips < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::LbVip

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_lb_vips(filters), 'vips')
        end

        def get(vip_id)
          if vip = service.get_lb_vip(vip_id).body['vip']
            new(vip)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
