
module Ox

  # An Object that includes the HasAttrs module can have attributes which are a Hash of String values and either String
  # or Symbol keys.
  #
  # To access the attributes there are several options. One is to walk the attributes. The easiest for simple regularly
  # formatted XML is to reference the attributes simply by name.
  module HasAttrs
    # Returns all the attributes of the Instruct as a Hash.
    # *return* [Hash] all attributes and attribute values.
    def attributes
      @attributes = { } if !instance_variable_defined?(:@attributes) or @attributes.nil?
      @attributes
    end
    
    # Returns the value of an attribute.
    # - +attr+ [Symbol|String] attribute name or key to return the value for
    def [](attr)
      return nil unless instance_variable_defined?(:@attributes) and @attributes.is_a?(Hash)
      @attributes[attr] or (attr.is_a?(String) ? @attributes[attr.to_sym] : @attributes[attr.to_s])
    end

    # Adds or set an attribute of the Instruct.
    # - +attr+ [Symbol|String] attribute name or key
    # - +value+ [Object] value for the attribute
    def []=(attr, value)
      raise "argument to [] must be a Symbol or a String." unless attr.is_a?(Symbol) or attr.is_a?(String)
      @attributes = { } if !instance_variable_defined?(:@attributes) or @attributes.nil?
      @attributes[attr] = value.to_s
    end
    
    # Handles the 'easy' API that allows navigating a simple XML by
    # referencing attributes by name.
    # - +id+ [Symbol] element or attribute name
    # *return* [String|nil] the attribute value
    # _raise_ [NoMethodError] if no match is found
    def method_missing(id, *args, &block)
      ids = id.to_s
      if instance_variable_defined?(:@attributes)
        return @attributes[id] if @attributes.has_key?(id)
        return @attributes[ids] if @attributes.has_key?(ids)
      end
      raise NoMethodError.new("#{ids} not found", name)
    end

  end # HasAttrs
end # Ox
