require 'fog/openstack/models/model'

module Fog
  module Network
    class OpenStack
      class Extension < Fog::OpenStack::Model
        identity :id
        attribute :name
        attribute :links
        attribute :description
        attribute :alias
      end
    end
  end
end
