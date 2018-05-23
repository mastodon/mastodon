class RDF::Query
  ##
  # An RDF query variable.
  #
  # @example Creating a named unbound variable
  #   var = RDF::Query::Variable.new(:x)
  #   var.unbound?   #=> true
  #   var.value      #=> nil
  #
  # @example Creating an anonymous unbound variable
  #   var = RDF::Query::Variable.new
  #   var.name       #=> :g2166151240
  #
  # @example Unbound variables match any value
  #   var === RDF::Literal(42)     #=> true
  #
  # @example Creating a bound variable
  #   var = RDF::Query::Variable.new(:y, 123)
  #   var.bound?     #=> true
  #   var.value      #=> 123
  #
  # @example Bound variables match only their actual value
  #   var = RDF::Query::Variable.new(:y, 123)
  #   var === 42     #=> false
  #   var === 123    #=> true
  #
  # @example Getting the variable name
  #   var = RDF::Query::Variable.new(:y, 123)
  #   var.named?     #=> true
  #   var.name       #=> :y
  #   var.to_sym     #=> :y
  #
  # @example Rebinding a variable returns the previous value
  #   var.bind!(456) #=> 123
  #   var.value      #=> 456
  #
  # @example Unbinding a previously bound variable
  #   var.unbind!
  #   var.unbound?   #=> true
  #
  # @example Getting the string representation of a variable
  #   var = RDF::Query::Variable.new(:x)
  #   var.to_s       #=> "?x"
  #   var = RDF::Query::Variable.new(:y, 123)
  #   var.to_s       #=> "?y=123"
  #
  class Variable
    include RDF::Term

    ##
    # The variable's name.
    #
    # @return [Symbol]
    attr_accessor :name
    alias_method :to_sym, :name

    ##
    # The variable's value.
    #
    # @return [RDF::Term]
    attr_accessor :value

    ##
    # @param  [Symbol, #to_sym] name
    #   the variable name
    # @param  [RDF::Term] value
    #   an optional variable value
    def initialize(name = nil, value = nil)
      @name  = (name || "g#{__id__.to_i.abs}").to_sym
      @value = value
    end

    ##
    # Returns `true`.
    #
    # @return [Boolean]
    # @see    RDF::Term#variable?
    # @since  0.1.7
    def variable? 
      true
    end

    ##
    # Returns `true` if this variable has a name.
    #
    # @return [Boolean]
    def named?
      true
    end

    ##
    # Returns `true` if this variable is bound.
    #
    # @return [Boolean]
    def bound?
      !unbound?
    end

    ##
    # Returns `true` if this variable is unbound.
    #
    # @return [Boolean]
    def unbound?
      value.nil?
    end

    ##
    # Returns `true` if this variable is distinguished.
    #
    # @return [Boolean]
    def distinguished?
      @distinguished.nil? || @distinguished
    end

    ##
    # Sets if variable is distinguished or non-distinguished.
    # By default, variables are distinguished
    #
    # @return [Boolean]
    def distinguished=(value)
      @distinguished = value
    end

    ##
    # Rebinds this variable to the given `value`.
    #
    # @param  [RDF::Term] value
    # @return [RDF::Term] the previous value, if any.
    def bind(value)
      old_value = self.value
      self.value = value
      old_value
    end
    alias_method :bind!, :bind

    ##
    # Unbinds this variable, discarding any currently bound value.
    #
    # @return [RDF::Term] the previous value, if any.
    def unbind
      old_value = self.value
      self.value = nil
      old_value
    end
    alias_method :unbind!, :unbind

    ##
    # Returns this variable as `Hash`.
    #
    # @return [Hash{Symbol => RDF::Query::Variable}]
    def variables
      {name => self}
    end
    alias_method :to_h, :variables

    ##
    # Returns this variable's bindings (if any) as a `Hash`.
    #
    # @return [Hash{Symbol => RDF::Term}]
    def bindings
      unbound? ? {} : {name => value}
    end

    ##
    # Returns a hash code for this variable.
    #
    # @return [Integer]
    # @since  0.3.0
    def hash
      @name.hash
    end

    ##
    # Returns `true` if this variable is equivalent to a given `other`
    # variable. Or, to another Term if bound, or to any other Term
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def eql?(other)
      if unbound?
        other.is_a?(RDF::Term) # match any Term when unbound
      elsif other.is_a?(RDF::Query::Variable)
        @name.eql?(other.name)
      else
        value.eql?(other)
      end
    end
    alias_method :==, :eql?

    ##
    # Compares this variable with the given value.
    #
    # @param  [RDF::Term] other
    # @return [Boolean]
    def ===(other)
      if unbound?
        other.is_a?(RDF::Term) # match any Term when unbound
      else
        value === other
      end
    end

    ##
    # Returns a string representation of this variable.
    #
    # Distinguished variables are indicated with a single `?`.
    #
    # Non-distinguished variables are indicated with a double `??`
    #
    # @example
    #   v = Variable.new("a")
    #   v.to_s => '?a'
    #   v.distinguished = false
    #   v.to_s => '??a'
    #
    # @return [String]
    def to_s
      prefix = distinguished? ? '?' : "??"
      unbound? ? "#{prefix}#{name}" : "#{prefix}#{name}=#{value}"
    end
  end # Variable
end # RDF::Query
