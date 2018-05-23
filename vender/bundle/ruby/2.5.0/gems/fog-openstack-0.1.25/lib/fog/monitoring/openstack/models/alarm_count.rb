require 'fog/openstack/models/model'

module Fog
  module Monitoring
    class OpenStack
      class AlarmCount < Fog::OpenStack::Model
        attribute :links
        attribute :columns
        attribute :counts

        def to_s
          name
        end
      end
    end
  end
end
