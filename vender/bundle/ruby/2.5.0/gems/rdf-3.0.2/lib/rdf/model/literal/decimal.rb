module RDF; class Literal
  ##
  # A decimal literal.
  #
  # @example Arithmetic with decimal literals
  #   RDF::Literal(BigDecimal('1.0')) + 0.5   #=> RDF::Literal(BigDecimal('1.5'))
  #   RDF::Literal(BigDecimal('1.0')) - 0.5   #=> RDF::Literal(BigDecimal('0.5'))
  #   RDF::Literal(BigDecimal('1.0')) * 0.5   #=> RDF::Literal(BigDecimal('0.5'))
  #   RDF::Literal(BigDecimal('1.0')) / 0.5   #=> RDF::Literal(BigDecimal('2.0'))
  #
  # @see   http://www.w3.org/TR/xmlschema11-2/#decimal
  # @since 0.2.1
  class Decimal < Numeric
    DATATYPE = RDF::XSD.decimal
    GRAMMAR  = /^[\+\-]?\d+(\.\d*)?$/.freeze

    ##
    # @param  [String, BidDecimal, Numeric] value
    # @param  (see Literal#initialize)
    def initialize(value, datatype: nil, lexical: nil, **options)
      @datatype = RDF::URI(datatype || self.class.const_get(:DATATYPE))
      @string   = lexical || (value if value.is_a?(String))
      @object   = case
        when value.is_a?(::BigDecimal) then value
        when value.is_a?(::Float)      then BigDecimal(value.to_s)
        when value.is_a?(::Numeric)    then BigDecimal(value)
        else
          value = value.to_s
          value += "0" if value.end_with?(".")  # Normalization required in Ruby 2.4
          BigDecimal(value) rescue BigDecimal(0)
      end
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # @return [RDF::Literal] `self`
    # @see    http://www.w3.org/TR/xmlschema11-2/#decimal
    def canonicalize!
      # Can't use simple %f transformation due to special requirements from
      # N3 tests in representation
      @string = begin
        i, f = @object.to_s('F').split('.')
        i.sub!(/^\+?0+(\d)$/, '\1') # remove the optional leading '+' sign and any extra leading zeroes
        f = f[0, 16]                # truncate the fractional part after 15 decimal places
        f.sub!(/0*$/, '')           # remove any trailing zeroes
        f = '0' if f.empty?         # ...but there must be a digit to the right of the decimal point
        "#{i}.#{f}"
      end
      @object = BigDecimal(@string) unless @object.nil?
      self
    end

    ##
    # Returns the absolute value of `self`.
    #
    # @return [RDF::Literal]
    # @since  0.2.3
    def abs
      (d = to_d) && d > 0 ? self : RDF::Literal(d.abs)
    end

    ##
    # Returns the number with no fractional part that is closest to the argument. If there are two such numbers, then the one that is closest to positive infinity is returned. An error is raised if arg is not a numeric value.
    #
    # @return [RDF::Literal]
    def round
      self.class.new(to_d.round)
    end

    ##
    # Returns the smallest integer greater than or equal to `self`.
    #
    # @example
    #   RDF::Literal(1).ceil            #=> RDF::Literal(1)
    #
    # @return [RDF::Literal]
    def ceil
      self.class.new(to_d.ceil)
    end

    ##
    # Returns the largest integer less than or equal to `self`.
    #
    # @example
    #   RDF::Literal(1).floor            #=> RDF::Literal(1)
    #
    # @return [RDF::Literal]
    def floor
      self.class.new(to_d.floor)
    end

    ##
    # Returns `true` if the value is zero.
    #
    # @return [Boolean]
    # @since  0.2.3
    def zero?
      to_d.zero?
    end

    ##
    # Returns `self` if the value is not zero, `nil` otherwise.
    #
    # @return [Boolean]
    # @since  0.2.3
    def nonzero?
      to_d.nonzero? ? self : nil
    end

    ##
    # Returns the value as a string.
    #
    # @return [String]
    # @see    BigDecimal#to_s
    def to_s
      @string || @object.to_s('F')
    end
  end # Decimal
end; end # RDF::Literal
