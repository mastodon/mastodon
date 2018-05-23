require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v1/models/snapshot'
require 'fog/volume/openstack/models/snapshots'

module Fog
  module Volume
    class OpenStack
      class V1
        class Snapshots < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::Snapshot
          include Fog::Volume::OpenStack::Snapshots
        end
      end
    end
  end
end
