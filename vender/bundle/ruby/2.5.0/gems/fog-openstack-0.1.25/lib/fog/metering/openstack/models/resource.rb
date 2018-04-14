require 'fog/openstack/models/model'

module Fog
  module Metering
    class OpenStack
      class Resource < Fog::OpenStack::Model
        identity :resource_id

        attribute :project_id
        attribute :user_id
        attribute :metadata
      end
    end
  end
end
