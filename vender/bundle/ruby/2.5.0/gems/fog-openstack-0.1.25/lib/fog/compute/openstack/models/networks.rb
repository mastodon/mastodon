require 'fog/openstack/models/collection'
require 'fog/compute/openstack/models/network'

module Fog
  module Compute
    class OpenStack
      class Networks < Fog::OpenStack::Collection
        model Fog::Compute::OpenStack::Network

        attribute :server

        def all
          requires :server

          networks = []
          server.addresses.each_with_index do |address, index|
            networks << {
              :id        => index + 1,
              :name      => address[0],
              :addresses => address[1].map { |a| a['addr'] }
            }
          end

          # TODO: convert to load_response?
          load(networks)
        end
      end # class Networks
    end # class OpenStack
  end # module Compute
end # module Fog
