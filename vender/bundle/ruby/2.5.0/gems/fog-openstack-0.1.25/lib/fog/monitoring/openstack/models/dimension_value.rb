require 'fog/openstack/models/model'

module Fog
  module Monitoring
    class OpenStack
      class DimensionValue < Fog::OpenStack::Model
        identity :id

        attribute :metric_name
        attribute :dimension_name
        attribute :values

        def to_s
          name
        end
      end
    end
  end
end
