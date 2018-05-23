module Fog
  module DNS
    class OpenStack < Fog::Service
      # Fog::DNS::OpenStack.new() will return a Fog::DNS::OpenStack::V2 or a Fog::DNS::OpenStack::V1,
      # choosing the latest available
      def self.new(args = {})
        @openstack_auth_uri = URI.parse(args[:openstack_auth_url]) if args[:openstack_auth_url]
        if inspect == 'Fog::DNS::OpenStack'
          service = Fog::DNS::OpenStack::V2.new(args) unless args.empty?
          service ||= Fog::DNS::OpenStack::V1.new(args)
        else
          service = Fog::Service.new(args)
        end
        service
      end
    end
  end
end
