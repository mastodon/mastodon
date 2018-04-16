require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v2/models/volume'
require 'fog/volume/openstack/models/volumes'

module Fog
  module Volume
    class OpenStack
      class V2
        class Volumes < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V2::Volume
          include Fog::Volume::OpenStack::Volumes
        end
      end
    end
  end
end
