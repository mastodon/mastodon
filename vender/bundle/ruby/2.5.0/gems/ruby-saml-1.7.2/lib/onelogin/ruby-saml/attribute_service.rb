module OneLogin
  module RubySaml

    # SAML2 AttributeService. Auxiliary class to build the AttributeService of the SP Metadata
    #
    class AttributeService
      attr_reader :attributes
      attr_reader :name
      attr_reader :index

      # Initializes the AttributeService, set the index value as 1 and an empty array as attributes
      #
      def initialize
        @index = "1"
        @attributes = []
      end

      def configure(&block)
        instance_eval &block
      end

      # @return [Boolean] True if the AttributeService object has been initialized and set with the required values
      #                   (has attributes and a name)
      def configured?
        @attributes.length > 0 && !@name.nil?
      end

      # Set a name to the service
      # @param name [String] The service name
      #
      def service_name(name)
        @name = name
      end

      # Set an index to the service
      # @param index [Integer] An index
      #
      def service_index(index)
        @index = index
      end

      # Add an AttributeService
      # @param options [Hash] AttributeService option values
      #   add_attribute(
      #                 :name => "Name",
      #                 :name_format => "Name Format",
      #                 :index => 1,
      #                 :friendly_name => "Friendly Name",
      #                 :attribute_value => "Attribute Value"
      #                )
      #
      def add_attribute(options={})
        attributes << options
      end
    end
  end
end
