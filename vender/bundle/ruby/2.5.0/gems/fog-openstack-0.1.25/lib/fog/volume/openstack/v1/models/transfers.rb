require 'fog/openstack/models/collection'
require 'fog/volume/openstack/v1/models/transfer'
require 'fog/volume/openstack/models/transfers'

module Fog
  module Volume
    class OpenStack
      class V1
        class Transfers < Fog::OpenStack::Collection
          model Fog::Volume::OpenStack::V1::Transfer
          include Fog::Volume::OpenStack::Transfers
        end
      end
    end
  end
end
