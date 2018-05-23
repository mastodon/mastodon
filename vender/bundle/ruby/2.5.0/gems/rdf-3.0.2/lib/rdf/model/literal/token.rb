module RDF; class Literal
  ##
  # A token literal.
  #
  # @see   http://www.w3.org/TR/xmlschema11-2/#token
  # @since 0.2.3
  class Token < Literal
    DATATYPE = RDF::XSD.token
    GRAMMAR  = /\A[^\x0D\x0A\x09]+\z/i.freeze # FIXME

    ##
    # @param  [String, Symbol, #to_sym]  value
    # @param  (see Literal#initialize)
    def initialize(value, datatype: nil, lexical: nil, **options)
      @datatype = RDF::URI(datatype || self.class.const_get(:DATATYPE))
      @string   = lexical || (value if value.is_a?(String))
      @object   = value.is_a?(Symbol) ? value : value.to_sym
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # @return [RDF::Literal] `self`
    # @see    http://www.w3.org/TR/xmlschema11-2/#boolean
    def canonicalize!
      @string = @object.to_s if @object
      self
    end

    ##
    # Returns the value as a symbol.
    #
    # @return [Symbol]
    def to_sym
      @object.to_sym
    end

    ##
    # Returns the value as a string.
    #
    # @return [String]
    def to_s
      @string || @object.to_s
    end
  end # Token
end; end # RDF::Literal
