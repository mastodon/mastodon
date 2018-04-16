module RDF; class Literal
  ##
  # A boolean literal.
  #
  # @see   http://www.w3.org/TR/xmlschema11-2/#boolean
  # @since 0.2.1
  class Boolean < Literal
    DATATYPE = RDF::XSD.boolean
    GRAMMAR  = /^(true|false|1|0)$/.freeze
    TRUES    = %w(true  1).freeze
    FALSES   = %w(false 0).freeze

    ##
    # @param  [String, Boolean] value
    # @param  (see Literal#initialize)
    def initialize(value, datatype: nil, lexical: nil, **options)
      @datatype = RDF::URI(datatype || self.class.const_get(:DATATYPE))
      @string   = lexical || (value if value.is_a?(String))
      @object   = case
        when true.equal?(value)  then true
        when false.equal?(value) then false
        when TRUES.include?(value.to_s.downcase)  then true
        when FALSES.include?(value.to_s.downcase) then false
        else value
      end
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # @return [RDF::Literal] `self`
    # @see    http://www.w3.org/TR/xmlschema11-2/#boolean-canonical-representation
    def canonicalize!
      @string = (@object ? :true : :false).to_s
      self
    end

    ##
    # Compares this literal to `other` for sorting purposes.
    #
    # @param  [Object] other
    # @return [Integer] `-1`, `0`, or `1`
    # @since  0.3.0
    def <=>(other)
      case other
        when TrueClass, FalseClass
          to_i <=> (other ? 1 : 0)
        when RDF::Literal::Boolean
          to_i <=> other.to_i
        else super
      end
    end

    ##
    # Returns `true` if this literal is equivalent to `other`.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def ==(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      other = Literal::Boolean.new(other) if other.class == TrueClass || other.class == FalseClass

      case other
      when Literal::Boolean
        return super unless other.valid?
        (cmp = (self <=> other)) ? cmp.zero? : false
      else
        super
      end
    end
    
    ##
    # Returns the value as a string.
    #
    # @return [String]
    def to_s
      @string || @object.to_s
    end

    ##
    # Returns the value as an integer.
    #
    # @return [Integer] `0` or `1`
    # @since  0.3.0
    def to_i
      @object ? 1 : 0
    end

    ##
    # Returns `true` if this value is `true`.
    #
    # @return [Boolean]
    def true?
      @object.equal?(true)
    end

    ##
    # Returns `true` if this value is `false`.
    #
    # @return [Boolean]
    def false?
      @object.equal?(false)
    end

    ##
    # Returns a developer-friendly representation of `self`.
    #
    # @return [String]
    def inspect
      case
        when self.equal?(RDF::Literal::TRUE)  then 'RDF::Literal::TRUE'
        when self.equal?(RDF::Literal::FALSE) then 'RDF::Literal::FALSE'
        else super
      end
    end
  end # Boolean
end; end # RDF::Literal
