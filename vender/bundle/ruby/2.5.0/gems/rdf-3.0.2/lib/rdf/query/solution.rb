class RDF::Query
  ##
  # An RDF query solution.
  #
  # @example Iterating over every binding in the solution
  #   solution.each_binding  { |name, value| puts value.inspect }
  #   solution.each_variable { |variable| puts variable.value.inspect }
  #
  # @example Iterating over every value in the solution
  #   solution.each_value    { |value| puts value.inspect }
  #
  # @example Checking whether a variable is bound or unbound
  #   solution.bound?(:title)
  #   solution.unbound?(:mbox)
  #
  # @example Retrieving the value of a bound variable
  #   solution[:mbox]
  #   solution.mbox
  #
  # @example Retrieving all bindings in the solution as a `Hash`
  #   solution.to_h       #=> {mbox: "jrhacker@example.org", ...}
  #
  class Solution
    # Undefine all superfluous instance methods:
    undef_method(*instance_methods.
                  map(&:to_s).
                  select {|m| m =~ /^\w+$/}.
                  reject {|m| %w(object_id dup instance_eval inspect to_s private_methods class should should_not pretty_print).include?(m) || m[0,2] == '__'}.
                  map(&:to_sym))

    include Enumerable

    ##
    # Initializes the query solution.
    #
    # @param  [Hash{Symbol => RDF::Term}] bindings
    # @yield  [solution]
    def initialize(bindings = {}, &block)
      @bindings = bindings.to_h

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else instance_eval(&block)
        end
      end
    end

    # @private
    attr_reader :bindings

    ##
    # Enumerates over every variable binding in this solution.
    #
    # @yield  [name, value]
    # @yieldparam [Symbol] name
    # @yieldparam [RDF::Term] value
    # @return [Enumerator]
    def each_binding(&block)
      @bindings.each(&block)
    end
    alias_method :each, :each_binding

    ##
    # Enumerates over every variable name in this solution.
    #
    # @yield  [name]
    # @yieldparam [Symbol] name
    # @return [Enumerator]
    def each_name(&block)
      @bindings.each_key(&block)
    end
    alias_method :each_key, :each_name

    ##
    # Enumerates over every variable value in this solution.
    #
    # @yield  [value]
    # @yieldparam [RDF::Term] value
    # @return [Enumerator]
    def each_value(&block)
      @bindings.each_value(&block)
    end

    ##
    # Returns `true` if this solution contains bindings for any of the given
    # `variables`.
    #
    # @param  [Array<Symbol, #to_sym>] variables
    #   an array of variables to check
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def has_variables?(variables)
      variables.any? { |variable| bound?(variable) }
    end

    ##
    # Enumerates over every variable in this solution.
    #
    # @yield  [variable]
    # @yieldparam [Variable]
    # @return [Enumerator]
    def each_variable
      @bindings.each do |name, value|
        yield Variable.new(name, value)
      end
    end

    ##
    # Returns `true` if the variable `name` is bound in this solution.
    #
    # @param  [Symbol, #to_sym] name
    #   the variable name
    # @return [Boolean] `true` or `false`
    def bound?(name)
      !unbound?(name)
    end

    ##
    # Returns `true` if the variable `name` is unbound in this solution.
    #
    # @param  [Symbol, #to_sym] name
    #   the variable name
    # @return [Boolean] `true` or `false`
    def unbound?(name)
      @bindings[name.to_sym].nil?
    end

    ##
    # Returns the value of the variable `name`.
    #
    # @param  [Symbol, #to_sym] name
    #   the variable name
    # @return [RDF::Term]
    def [](name)
      @bindings[name.to_sym]
    end

    ##
    # Binds or rebinds the variable `name` to the given `value`.
    #
    # @param  [Symbol, #to_sym] name
    #   the variable name
    # @param  [RDF::Term] value
    # @return [RDF::Term]
    # @since  0.3.0
    def []=(name, value)
      @bindings[name.to_sym] = value.is_a?(RDF::Term) ? value : RDF::Literal(value)
    end

    ##
    # Merges the bindings from the given `other` query solution into this
    # one, overwriting any existing ones having the same name.
    #
    # @param  [RDF::Query::Solution, #to_h] other
    #   another query solution or hash bindings
    # @return [void] self
    # @since  0.3.0
    def merge!(other)
      @bindings.merge!(other.to_h)
      self
    end

    ##
    # Merges the bindings from the given `other` query solution with a copy
    # of this one.
    #
    # @param  [RDF::Query::Solution, #to_h] other
    #   another query solution or hash bindings
    # @return [RDF::Query::Solution]
    # @since  0.3.0
    def merge(other)
      self.class.new(@bindings.dup).merge!(other)
    end

    ##
    # Duplicate solution, preserving patterns
    # @return [RDF::Statement]
    def dup
      merge({})
    end

    ##
    # Compatible Mappings
    #
    # Two solution mappings u1 and u2 are compatible if, for every variable v in dom(u1) and in dom(u2), u1(v) = u2(v).
    #
    # @param [RDF::Query::Solution, #to_h] other
    #   another query solution or hash bindings
    # @return [Boolean]
    # @see http://www.w3.org/TR/2013/REC-sparql11-query-20130321/#defn_algCompatibleMapping
    def compatible?(other)
      @bindings.all? do |k, v|
        !other.to_h.has_key?(k) || other[k].eql?(v)
      end
    end

    ##
    # Disjoint mapping
    #
    # A solution is disjoint with another solution if it shares no common variables in their domains.
    #
    # @param [RDF::Query::Solution] other
    # @return [Boolean]
    # @see http://www.w3.org/TR/2013/REC-sparql11-query-20130321/#defn_algMinus
    def disjoint?(other)
      @bindings.none? do |k, v|
        v && other.to_h.has_key?(k) && other[k].eql?(v)
      end
    end

    ##
    # Isomorphic Mappings
    # Two solution mappings u1 and u2 are isomorphic if,
    # for every variable v in dom(u1) and in dom(u2), u1(v) = u2(v).
    #
    # @param [RDF::Query::Solution, #to_h] other
    #   another query solution or hash bindings
    # @return [Boolean]
    def isomorphic_with?(other)
      @bindings.all? do |k, v|
        !other.to_h.has_key?(k) || other[k].eql?(v)
      end
    end
    
    ##
    # @return [Array<Array(Symbol, RDF::Term)>}
    def to_a
      @bindings.to_a
    end

    ##
    # @return [Hash{Symbol => RDF::Term}}
    def to_h
      @bindings.dup
    end
    
    ##
    # Integer hash of this solution
    # @return [Integer]
    def hash
      @bindings.hash
    end
    
    ##
    # Equivalence of solution
    def eql?(other)
      other.is_a?(Solution) && @bindings.eql?(other.bindings)
    end
    alias_method :==, :eql?

    ##
    # Equals of solution
    def ==(other)
      other.is_a?(Solution) && @bindings == other.bindings
    end

    ##
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, @bindings.inspect)
    end

  protected

    ##
    # @overload binding(name)
    #   Return the binding for this name
    #
    #   @param  [Symbol] name
    #   @return [RDF::Term]
    def method_missing(name, *args, &block)
      if args.empty? && @bindings.has_key?(name.to_sym)
        @bindings[name.to_sym]
      else
        super # raises NoMethodError
      end
    end

    ##
    # @return [Boolean]
    def respond_to_missing?(name, include_private = false)
      @bindings.has_key?(name.to_sym) || super
    end
  end # Solution
end # RDF::Query
