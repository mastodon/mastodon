require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v2/models/snapshot'
require 'fog/volume/openstack/models/snapshots'

module Fog
  module Volume
    class OpenStack
      class V2
        class Snapshots < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V2::Snapshot
          include Fog::Volume::OpenStack::Snapshots
        end
      end
    end
  end
end
