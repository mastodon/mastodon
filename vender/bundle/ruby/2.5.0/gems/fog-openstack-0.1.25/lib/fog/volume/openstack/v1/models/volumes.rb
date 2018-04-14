require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v1/models/volume'
require 'fog/volume/openstack/models/volumes'

module Fog
  module Volume
    class OpenStack
      class V1
        class Volumes < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::Volume
          include Fog::Volume::OpenStack::Volumes
        end
      end
    end
  end
end
