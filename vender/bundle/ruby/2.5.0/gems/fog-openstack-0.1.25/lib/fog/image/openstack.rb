

module Fog
  module Image
    class OpenStack < Fog::Service
      # Fog::Image::OpenStack.new() will return a Fog::Image::OpenStack::V2 or a Fog::Image::OpenStack::V1,
      #  choosing the latest available
      def self.new(args = {})
        @openstack_auth_uri = URI.parse(args[:openstack_auth_url]) if args[:openstack_auth_url]
        if inspect == 'Fog::Image::OpenStack'
          service = Fog::Image::OpenStack::V2.new(args) unless args.empty?
          service ||= Fog::Image::OpenStack::V1.new(args)
        else
          service = Fog::Service.new(args)
        end
        service
      end
    end
  end
end
