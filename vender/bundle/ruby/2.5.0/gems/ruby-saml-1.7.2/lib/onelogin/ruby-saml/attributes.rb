module OneLogin
  module RubySaml

    # SAML2 Attributes. Parse the Attributes from the AttributeStatement of the SAML Response. 
    #
    class Attributes
      include Enumerable

      attr_reader :attributes

      # By default Attributes#[] is backwards compatible and
      # returns only the first value for the attribute
      # Setting this to `false` returns all values for an attribute
      @@single_value_compatibility = true

      # @return [Boolean] Get current status of backwards compatibility mode.
      #
      def self.single_value_compatibility
        @@single_value_compatibility
      end

      # Sets the backwards compatibility mode on/off.
      # @param value [Boolean]
      #
      def self.single_value_compatibility=(value)
        @@single_value_compatibility = value
      end

      # @param attrs [Hash] The +attrs+ must be a Hash with attribute names as keys and **arrays** as values:
      #    Attributes.new({
      #      'name' => ['value1', 'value2'],
      #      'mail' => ['value1'],
      #    })
      #
      def initialize(attrs = {})
        @attributes = attrs
      end


      # Iterate over all attributes
      #
      def each
        attributes.each{|name, values| yield name, values}
      end

      
      # Test attribute presence by name
      # @param name [String] The attribute name to be checked
      #
      def include?(name)
        attributes.has_key?(canonize_name(name))
      end
      
      # Return first value for an attribute
      # @param name [String] The attribute name
      # @return [String] The value (First occurrence)
      #
      def single(name)
        attributes[canonize_name(name)].first if include?(name)
      end

      # Return all values for an attribute
      # @param name [String] The attribute name
      # @return [Array] Values of the attribute
      #
      def multi(name)
        attributes[canonize_name(name)]
      end

      # Retrieve attribute value(s)
      # @param name [String] The attribute name
      # @return [String|Array] Depending on the single value compatibility status this returns:
      #                        - First value if single_value_compatibility = true
      #                          response.attributes['mail']  # => 'user@example.com'
      #                        - All values if single_value_compatibility = false
      #                          response.attributes['mail']  # => ['user@example.com','user@example.net']
      #
      def [](name)
        self.class.single_value_compatibility ? single(canonize_name(name)) : multi(canonize_name(name))
      end

      # @return [Array] Return all attributes as an array
      #
      def all
        attributes
      end

      # @param name [String] The attribute name
      # @param values [Array] The values
      #
      def set(name, values)
        attributes[canonize_name(name)] = values
      end
      alias_method :[]=, :set

      # @param name [String] The attribute name
      # @param values [Array] The values
      #
      def add(name, values = [])
        attributes[canonize_name(name)] ||= []
        attributes[canonize_name(name)] += Array(values)
      end

      # Make comparable to another Attributes collection based on attributes
      # @param other [Attributes] An Attributes object to compare with
      # @return [Boolean] True if are contains the same attributes and values
      #
      def ==(other)
        if other.is_a?(Attributes)
          all == other.all
        else
          super
        end
      end

      protected

      # stringifies all names so both 'email' and :email return the same result
      # @param name [String] The attribute name
      # @return [String] stringified name
      #
      def canonize_name(name)
        name.to_s
      end

    end
  end
end
