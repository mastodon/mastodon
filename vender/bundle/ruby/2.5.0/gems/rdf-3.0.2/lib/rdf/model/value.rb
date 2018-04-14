module RDF
  ##
  # An RDF value.
  #
  # This is the basis for the RDF.rb class hierarchy. Anything that can be a
  # term of {RDF::Statement RDF statements} should directly or indirectly
  # include this module, but it does not define classes that can be included
  # within a {RDF::Statement}, for this see {RDF::Term}.
  #
  # @example Checking if a value is a resource (blank node or URI reference)
  #   value.resource?
  #
  # @example Checking if a value is a blank node
  #   value.node?
  #
  # @example Checking if a value is a URI reference
  #   value.uri?
  #   value.iri?
  #
  # @example Checking if a value is a literal
  #   value.literal?
  #
  # @see RDF::Literal
  # @see RDF::Node
  # @see RDF::Resource
  # @see RDF::URI
  # @see RDF::Graph
  # @see RDF::List
  # @see RDF::Statement
  module Value
    ##
    # Returns `true` if `self` is a {RDF::Graph}.
    #
    # @return [Boolean]
    def graph?
      false
    end

    ##
    # Is this a {RDF::Statement}?
    #
    # @return [Boolean]
    def statement?
      false
    end

    ##
    # Is this a {RDF::List}?
    #
    # @return [Boolean]
    def list?
      false
    end

    ##
    # Is this a {RDF::Term}?
    #
    # @return [Boolean]
    def term?
      false
    end

    ##
    # Is this a {RDF::Resource}?
    #
    # @return [Boolean]
    def resource?
      false
    end

    ##
    # Is this a {RDF::Literal}?
    #
    # @return [Boolean]
    def literal?
      false
    end

    ##
    # Is this a {RDF::Node}, or does it contain a node?
    #
    # @return [Boolean]
    def node?
      false
    end

    ##
    # Is this an {RDF::IRI}?
    #
    # By default this is simply an alias for {RDF::Value#uri?}.
    #
    # @return [Boolean]
    def iri?
      uri?
    end

    ##
    # Is this an {RDF::URI}?
    #
    # @return [Boolean]
    def uri?
      false
    end

    ##
    # Is this a {RDF::Query::Variable}, or does it contain a variable?
    #
    # @return [Boolean]
    # @since  0.1.7
    def variable?
      false
    end

    ##
    # Is this constant, or are all of its components constant?
    #
    # Same as `!variable?`
    #
    # @return [Boolean] `true` or `false`
    # @see    #variable?
    def constant?
      !(variable?)
    end

    ##
    # Is this value named?
    #
    # @return [Boolean] `true` or `false`
    def anonymous?
      false
    end

    ##
    # Is this value valid, and composed only of valid components?
    #
    # @return [Boolean] `true` or `false`
    # @since  0.3.9
    def valid?
      true
    end

    ##
    # Is this value invalid, or is it composed of any invalid components?
    #
    # @return [Boolean] `true` or `false`
    # @since  0.2.1
    def invalid?
      !valid?
    end

    ##
    # Default validate! implementation, overridden in concrete classes
    # @return [RDF::Value] `self`
    # @raise  [ArgumentError] if the value is invalid
    # @since  0.3.9
    def validate!
      raise ArgumentError, "#{self.inspect} is not valid" if invalid?
      self
    end
    alias_method :validate, :validate!

    ##
    # Returns `true` if this Value starts with the given `string`.
    #
    # @example
    #   RDF::URI('http://example.org/').start_with?('http')     #=> true
    #   RDF::Node('_:foo').start_with?('_:bar')                 #=> false
    #   RDF::Litera('Apple').start_with?('Orange')              #=> false
    #
    # @param  [String, #to_s] string
    # @return [Boolean] `true` or `false`
    # @see    String#start_with?
    # @since  0.3.0
    def start_with?(string)
      to_s.start_with?(string.to_s)
    end
    alias_method :starts_with?, :start_with?

    ##
    # Returns a copy of this value converted into its canonical
    # representation.
    #
    # @return [RDF::Value]
    # @since  1.0.8
    def canonicalize
      self.dup.canonicalize!
    end

    ##
    # Converts this value into its canonical representation.
    #
    # Should be overridden by concrete classes.
    #
    # @return [RDF::Value] `self`
    # @since  1.0.8
    def canonicalize!
      self
    end

    ##
    # Returns an `RDF::Value` representation of `self`.
    #
    # @return [RDF::Value]
    def to_rdf
      self
    end

    ##
    # Returns an `RDF::Term` representation of `self`.
    #
    # @return [RDF::Value]
    def to_term
      raise NotImplementedError, "#{self.class}#read_triple" # override in subclasses
    end

    ##
    # Returns a developer-friendly representation of `self`.
    #
    # The result will be of the format `#<RDF::Value::0x12345678(...)>`,
    # where `...` is the string returned by `#to_s`.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, to_s)
    end

    ##
    # Outputs a developer-friendly representation of `self` to `stderr`.
    #
    # @return [void]
    def inspect!
      warn(inspect)
    end
    
    ##
    # Default implementation of `type_error`, which returns false.
    # Classes including RDF::TypeCheck will raise TypeError
    # instead.
    #
    # @return [false]
    def type_error(message)
      false
    end
  end # Value
end # RDF
