require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v1/models/backup'
require 'fog/volume/openstack/models/backups'

module Fog
  module Volume
    class OpenStack
      class V1
        class Backups < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::Backup
          include Fog::Volume::OpenStack::Backups
        end
      end
    end
  end
end
