module Fog
  module Workflow
    class OpenStack < Fog::Service
      # Fog::Workflow::OpenStack.new() will return a Fog::Workflow::OpenStack::V2
      #  Will choose the latest available once Mistral V3 is released.
      def self.new(args = {})
        @openstack_auth_uri = URI.parse(args[:openstack_auth_url]) if args[:openstack_auth_url]
        Fog::Workflow::OpenStack::V2.new(args)
      end
    end
  end
end
