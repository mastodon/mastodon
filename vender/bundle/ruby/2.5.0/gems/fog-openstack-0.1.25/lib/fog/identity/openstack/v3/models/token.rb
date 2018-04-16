require 'fog/openstack/models/model'

module Fog
  module Identity
    class OpenStack
      class V3
        class Token < Fog::OpenStack::Model
          attribute :value
          attribute :catalog
          attribute :expires_at
          attribute :issued_at
          attribute :methods
          attribute :project
          attribute :roles
          attribute :user

          def to_s
            value
          end
        end
      end
    end
  end
end
