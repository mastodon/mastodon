require 'fog/openstack/models/model'

module Fog
  module SharedFileSystem
    class OpenStack
      class AvailabilityZone < Fog::OpenStack::Model
        identity :id

        attribute :name
        attribute :created_at
        attribute :updated_at
      end
    end
  end
end
