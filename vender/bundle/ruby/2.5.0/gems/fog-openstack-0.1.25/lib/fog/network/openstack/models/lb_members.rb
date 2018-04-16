require 'fog/openstack/models/collection'
require 'fog/network/openstack/models/lb_member'

module Fog
  module Network
    class OpenStack
      class LbMembers < Fog::OpenStack::Collection
        attribute :filters

        model Fog::Network::OpenStack::LbMember

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          filters = filters_arg
          load_response(service.list_lb_members(filters), 'members')
        end

        def get(member_id)
          if member = service.get_lb_member(member_id).body['member']
            new(member)
          end
        rescue Fog::Network::OpenStack::NotFound
          nil
        end
      end
    end
  end
end
