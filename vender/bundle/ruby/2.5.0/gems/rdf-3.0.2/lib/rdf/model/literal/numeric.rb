module RDF; class Literal
  ##
  # Shared methods and class ancestry for numeric literal classes.
  #
  # @since 0.3.0
  class Numeric < Literal
    ##
    # Compares this literal to `other` for sorting purposes.
    #
    # @param  [Object] other
    # @return [Integer] `-1`, `0`, or `1`
    # @since  0.3.0
    def <=>(other)
      case other
        when ::Numeric
          to_d <=> other
        when Double
          to_f <=> other.to_f
        when Numeric
          to_d <=> other.to_d
        else super
      end
    end

    ##
    # Returns `true` if this literal is equal to `other`.
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def ==(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Literal::Numeric
        return super unless other.valid?
        (cmp = (self <=> other)) ? cmp.zero? : false
      when RDF::URI, RDF::Node
        # Interpreting SPARQL data-r2/expr-equal/eq-2-2, numeric can't be compared with other types
        type_error("unable to determine whether #{self.inspect} and #{other.inspect} are equivalent")
      else
        super
      end
    end

    ##
    # Returns `self`.
    #
    # @return [RDF::Literal::Numeric]
    # @since  0.2.3
    def +@
      self # unary plus
    end

    ##
    # Returns `self` negated.
    #
    # @return [RDF::Literal::Numeric]
    # @since  0.2.3
    def -@
      self.class.new(-self.object)
    end

    ##
    # Returns the sum of `self` plus `other`.
    #
    # For xs:float or xs:double values, if one of the operands is a zero or a finite number
    # and the other is INF or -INF, INF or -INF is returned. If both operands are INF, INF is returned.
    # If both operands are -INF, -INF is returned. If one of the operands is INF
    # and the other is -INF, NaN is returned.
    # @param  [Literal::Numeric, #to_i, #to_f, #to_d] other
    # @return [RDF::Literal::Numeric]
    # @since  0.2.3
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-add
    def +(other)
      if self.class == Double || [Double, ::Float].include?(other.class)
        RDF::Literal::Double.new(to_f + other.to_f)
      elsif ((self.class == RDF::Literal::Float || other.class == RDF::Literal::Float) rescue false)
        RDF::Literal::Float.new(to_f + other.to_f)
      elsif self.class == Decimal || other.class == Decimal
        RDF::Literal::Decimal.new(to_d + (other.respond_to?(:to_d) ? other.to_d : BigDecimal(other.to_s)))
      else
        RDF::Literal::Integer.new(to_i + other.to_i)
      end
    end

    ##
    # Returns the difference of `self` minus `other`.
    #
    # @param  [Literal::Numeric, #to_i, #to_f, #to_d] other
    # @return [RDF::Literal::Numeric]
    # @since  0.2.3
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-subtract
    def -(other)
      if self.class == Double || [Double, ::Float].include?(other.class)
        RDF::Literal::Double.new(to_f - other.to_f)
      elsif ((self.class == RDF::Literal::Float || other.class == RDF::Literal::Float) rescue false)
        RDF::Literal::Float.new(to_f - other.to_f)
      elsif self.class == Decimal || other.class == Decimal
        RDF::Literal::Decimal.new(to_d - (other.respond_to?(:to_d) ? other.to_d : BigDecimal(other.to_s)))
      else
        RDF::Literal::Integer.new(to_i - other.to_i)
      end
    end

    ##
    # Returns the product of `self` times `other`.
    #
    # @param  [Literal::Numeric, #to_i, #to_f, #to_d] other
    # @return [RDF::Literal::Numeric]
    # @since  0.2.3
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-multiply
    def *(other)
      if self.class == Double || [Double, ::Float].include?(other.class)
        RDF::Literal::Double.new(to_f * other.to_f)
      elsif ((self.class == RDF::Literal::Float || other.class == RDF::Literal::Float) rescue false)
        RDF::Literal::Float.new(to_f * other.to_f)
      elsif self.class == Decimal || other.class == Decimal
        RDF::Literal::Decimal.new(to_d * (other.respond_to?(:to_d) ? other.to_d : BigDecimal(other.to_s)))
      else
        RDF::Literal::Integer.new(to_i * other.to_i)
      end
    end

    ##
    # Returns the quotient of `self` divided by `other`.
    #
    # As a special case, if the types of both $arg1 and $arg2 are xsd:integer,
    # then the return type is xsd:decimal.
    #
    # @param  [Literal::Numeric, #to_i, #to_f, #to_d] other
    # @return [RDF::Literal::Numeric]
    # @raise  [ZeroDivisionError] if divided by zero
    # @since  0.2.3
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-divide
    def /(other)
      if self.class == Double || [Double, ::Float].include?(other.class)
        RDF::Literal::Double.new(to_f / other.to_f)
      elsif ((self.class == RDF::Literal::Float || other.class == RDF::Literal::Float) rescue false)
        RDF::Literal::Float.new(to_f / other.to_f)
      else
        RDF::Literal::Decimal.new(to_d / (other.respond_to?(:to_d) ? other.to_d : BigDecimal(other.to_s)))
      end
    end

    ##
    # Returns the absolute value of `self`.
    #
    # @return [RDF::Literal]
    # @raise  [NotImplementedError] unless implemented in subclass
    def abs
      raise NotImplementedError
    end

    ##
    # Returns the number with no fractional part that is closest to the argument. If there are two such numbers, then the one that is closest to positive infinity is returned. An error is raised if arg is not a numeric value.
    #
    # @return [RDF::Literal]
    # @raise  [NotImplementedError] unless implemented in subclass
    def round
      raise NotImplementedError
    end

    ##
    # Returns the smallest integer greater than or equal to `self`.
    #
    # @example
    #   RDF::Literal(1).ceil            #=> RDF::Literal(1)
    #
    # @return [RDF::Literal]
    def ceil
      self
    end

    ##
    # Returns the largest integer less than or equal to `self`.
    #
    # @example
    #   RDF::Literal(1).floor            #=> RDF::Literal(1)
    #
    # @return [RDF::Literal]
    def floor
      self
    end

    ##
    # Returns the value as an integer.
    #
    # @return [Integer]
    def to_i
      @object.to_i
    end
    alias_method :to_int, :to_i
    alias_method :ord,    :to_i

    ##
    # Returns the value as a floating point number.
    #
    # The usual accuracy limits and errors of binary float arithmetic apply.
    #
    # @return [Float]
    # @see    BigDecimal#to_f
    def to_f
      @object.to_f
    end

    ##
    # Returns the value as a decimal number.
    #
    # @return [BigDecimal]
    def to_d
      @object.respond_to?(:to_d) ? @object.to_d : BigDecimal(@object.to_s)
    rescue FloatDomainError
      ::Float::NAN
    end

    ##
    # Returns the value as a rational number.
    #
    # @return [Rational]
    def to_r
      @object.to_r
    end
  end # Numeric
end; end # RDF::Literal
