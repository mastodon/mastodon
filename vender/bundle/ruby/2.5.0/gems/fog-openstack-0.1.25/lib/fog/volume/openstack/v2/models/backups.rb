require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v2/models/backup'
require 'fog/volume/openstack/models/backups'

module Fog
  module Volume
    class OpenStack
      class V2
        class Backups < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V2::Backup
          include Fog::Volume::OpenStack::Backups
        end
      end
    end
  end
end
