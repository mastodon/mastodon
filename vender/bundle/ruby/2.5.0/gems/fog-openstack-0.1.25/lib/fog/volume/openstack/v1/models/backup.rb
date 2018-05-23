require 'fog/volume/openstack/models/backup'

module Fog
  module Volume
    class OpenStack
      class V1
        class Backup < Fog::Volume::OpenStack::Backup
          identity :id

          superclass.attributes.each { |attrib| attribute attrib }
        end
      end
    end
  end
end
