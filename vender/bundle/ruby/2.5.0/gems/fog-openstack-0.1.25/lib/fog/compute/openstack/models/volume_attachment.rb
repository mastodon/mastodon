require 'fog/core/model'

module Fog
  module Compute
    class OpenStack
      class VolumeAttachment < Fog::Model
        identity :id

        attribute :serverId
        attribute :volumeId
        attribute :device
      end
    end
  end
end
