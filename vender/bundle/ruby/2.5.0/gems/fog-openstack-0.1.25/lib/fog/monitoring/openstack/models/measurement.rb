require 'fog/openstack/models/model'

module Fog
  module Monitoring
    class OpenStack
      class Measurement < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :dimensions
        attribute :columns
        attribute :measurements

        def to_s
          name
        end
      end
    end
  end
end
