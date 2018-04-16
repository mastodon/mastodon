module RDF; class Literal
  ##
  # An floating point number literal.
  #
  # @example Arithmetic with floating point literals
  #   RDF::Literal(1.0) + 0.5                 #=> RDF::Literal(1.5)
  #   RDF::Literal(3.0) - 6                   #=> RDF::Literal(-3.0)
  #   RDF::Literal(Math::PI) * 2              #=> RDF::Literal(Math::PI * 2)
  #   RDF::Literal(Math::PI) / 2              #=> RDF::Literal(Math::PI / 2)
  #
  # @see   http://www.w3.org/TR/xmlschema11-2/#double
  # @since 0.2.1
  class Double < Numeric
    DATATYPE = RDF::XSD.double
    GRAMMAR  = /^(?:NaN|\-?INF|[+\-]?(?:\d+(:?\.\d*)?|\.\d+)(?:[eE][\+\-]?\d+)?)$/.freeze

    ##
    # @param  [String, Float, #to_f] value
    # @param  (see Literal#initialize)
    def initialize(value, datatype: nil, lexical: nil, **options)
      @datatype = RDF::URI(datatype || self.class.const_get(:DATATYPE))
      @string   = lexical || (value if value.is_a?(String))
      @object   = case
        when value.is_a?(::String) then case value.upcase
          when '+INF'  then 1/0.0
          when 'INF'  then 1/0.0
          when '-INF' then -1/0.0
          when 'NAN'  then 0/0.0
          else Float(value.sub(/\.[eE]/, '.0E')) rescue nil
        end
        when value.is_a?(::Float)     then value
        when value.respond_to?(:to_f) then value.to_f
        else 0.0 # FIXME
      end
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # @return [RDF::Literal] `self`
    # @see    http://www.w3.org/TR/xmlschema11-2/#double
    def canonicalize!
      # Can't use simple %f transformation due to special requirements from
      # N3 tests in representation
      @string = case
        when @object.nan?      then 'NaN'
        when @object.infinite? then @object.to_s[0...-'inity'.length].upcase
        when @object.zero?     then '0.0E0'
        else
          i, f, e = ('%.15E' % @object.to_f).split(/[\.E]/)
          f.sub!(/0*$/, '')           # remove any trailing zeroes
          f = '0' if f.empty?         # ...but there must be a digit to the right of the decimal point
          e.sub!(/^(?:\+|(\-))?0+(\d+)$/, '\1\2') # remove the optional leading '+' sign and any extra leading zeroes
          "#{i}.#{f}E#{e}"
      end

      @object = case @string
      when 'NaN'  then 0/0.0
      when 'INF'  then 1/0.0
      when '-INF' then -1/0.0
      else             Float(@string)
      end

      self
    end

    ##
    # Returns `true` if this literal is equal to `other`.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def ==(other)
      if valid? && infinite? && other.respond_to?(:infinite?) && other.infinite?
        infinite? == other.infinite?
        # JRuby INF comparisons differ from MRI
      else
        super
      end
    end

    ##
    # Compares this literal to `other` for sorting purposes.
    #
    # @param  [Object] other
    # @return [Integer] `-1`, `0`, or `1`
    # @since  0.3.0
    def <=>(other)
      case other
        when ::Numeric
          to_f <=> other
        when RDF::Literal::Decimal
          to_f <=> other.to_d
        when RDF::Literal::Double
          to_f <=> other.to_f
        else super
      end
    end

    ##
    # Returns `true` if the value is an invalid IEEE floating point number.
    #
    # @example
    #   RDF::Literal(-1.0).nan?           #=> false
    #   RDF::Literal(1.0/0.0).nan?        #=> false
    #   RDF::Literal(0.0/0.0).nan?        #=> true
    #
    # @return [Boolean]
    # @since  0.2.3
    def nan?
      to_f.nan?
    end

    ##
    # Returns `true` if the value is a valid IEEE floating point number (it
    # is not infinite, and `nan?` is `false`).
    #
    # @example
    #   RDF::Literal(-1.0).finite?        #=> true
    #   RDF::Literal(1.0/0.0).finite?     #=> false
    #   RDF::Literal(0.0/0.0).finite?     #=> false
    #
    # @return [Boolean]
    # @since  0.2.3
    def finite?
      to_f.finite?
    end

    ##
    # Returns `nil`, `-1`, or `+1` depending on whether the value is finite,
    # `-INF`, or `+INF`.
    #
    # @example
    #   RDF::Literal(0.0/0.0).infinite?   #=> nil
    #   RDF::Literal(-1.0/0.0).infinite?  #=> -1
    #   RDF::Literal(+1.0/0.0).infinite?  #=> 1
    #
    # @return [Integer]
    # @since  0.2.3
    def infinite?
      to_f.infinite?
    end

    ##
    # Returns the smallest number greater than or equal to `self`.
    #
    # @example
    #   RDF::Literal(1.2).ceil            #=> RDF::Literal(2)
    #   RDF::Literal(-1.2).ceil           #=> RDF::Literal(-1)
    #   RDF::Literal(2.0).ceil            #=> RDF::Literal(2)
    #   RDF::Literal(-2.0).ceil           #=> RDF::Literal(-2)
    #
    # @return [RDF::Literal]
    # @since  0.2.3
    def ceil
      self.class.new(to_f.ceil)
    end

    ##
    # Returns the largest number less than or equal to `self`.
    #
    # @example
    #   RDF::Literal(1.2).floor           #=> RDF::Literal(1)
    #   RDF::Literal(-1.2).floor          #=> RDF::Literal(-2)
    #   RDF::Literal(2.0).floor           #=> RDF::Literal(2)
    #   RDF::Literal(-2.0).floor          #=> RDF::Literal(-2)
    #
    # @return [RDF::Literal]
    # @since  0.2.3
    def floor
      self.class.new(to_f.floor)
    end

    ##
    # Returns the absolute value of `self`.
    #
    # @return [RDF::Literal]
    # @since  0.2.3
    def abs
      (f = to_f) && f > 0 ? self : self.class.new(f.abs)
    end

    ##
    # Returns the number with no fractional part that is closest to the argument. If there are two such numbers, then the one that is closest to positive infinity is returned. An error is raised if arg is not a numeric value.
    #
    # @return [RDF::Literal]
    def round
      self.class.new(to_f.round)
    end

    ##
    # Returns `true` if the value is zero.
    #
    # @return [Boolean]
    # @since  0.2.3
    def zero?
      to_f.zero?
    end

    ##
    # Returns `self` if the value is not zero, `nil` otherwise.
    #
    # @return [Boolean]
    # @since  0.2.3
    def nonzero?
      to_f.nonzero? ? self : nil
    end

    ##
    # Returns the value as a string.
    #
    # @return [String]
    def to_s
      @string || case
        when @object.nan?      then 'NaN'
        when @object.infinite? then @object.to_s[0...-'inity'.length].upcase
        else @object.to_s
      end
    end
  end # Double
end; end # RDF::Literal
