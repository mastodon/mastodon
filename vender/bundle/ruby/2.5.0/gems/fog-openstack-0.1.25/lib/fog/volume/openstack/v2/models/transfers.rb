require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v2/models/transfer'
require 'fog/volume/openstack/models/transfers'

module Fog
  module Volume
    class OpenStack
      class V2
        class Transfers < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V2::Transfer
          include Fog::Volume::OpenStack::Transfers
        end
      end
    end
  end
end
