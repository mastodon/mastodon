module Fog
  module Core
    # This module covers the shared code used by models and collections
    # that deprecates the confusing usage of 'connection' which was
    # actually intended to be an instance of Fog::Service
    module DeprecatedConnectionAccessors
      # Sets the Service but using the wrong name!
      #
      # @deprecated The connection name was wrong and confusing since it refered to the service
      # @param [Fog::Service] service An instance of a Fog service this collection is for
      #
      def connection=(service)
        Fog::Logger.deprecation("#connection= is deprecated, pass :service in at creation [light_black](#{caller.first})[/]")
        @service = service
      end

      # Returns the Service the collection is part of
      #
      # @deprecated #connection is deprecated due to confusing name, use #service instead
      # @return [Fog::Service]
      #
      def connection
        Fog::Logger.deprecation("#connection is deprecated, use #service instead [light_black](#{caller.first})[/]")
        @service
      end

      # Prepares the value of the service based on the passed attributes
      #
      # @note Intended for use where the service is required before the normal
      #   initializer runs. The logic is run there with deprecation warnings.
      #
      # @param [Hash] attributes
      # @return [Fog::Service]
      #
      def prepare_service_value(attributes)
        @service = attributes[:service] || attributes[:connection]
      end
    end
  end
end
