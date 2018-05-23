require_relative 'base'

module Fog
  module ContainerInfra
    class OpenStack
      class Certificate < Fog::ContainerInfra::OpenStack::Base
        identity :bay_uuid

        attribute :pem
        attribute :csr

        def create
          requires :csr, :bay_uuid
          merge_attributes(service.create_certificate(attributes).body)
          self
        end
      end
    end
  end
end
