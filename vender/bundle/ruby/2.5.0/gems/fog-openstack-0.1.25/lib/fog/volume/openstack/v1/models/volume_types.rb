require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v1/models/volume_type'
require 'fog/volume/openstack/models/volume_types'

module Fog
  module Volume
    class OpenStack
      class V1
        class VolumeTypes < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::VolumeType
          include Fog::Volume::OpenStack::VolumeTypes
        end
      end
    end
  end
end
