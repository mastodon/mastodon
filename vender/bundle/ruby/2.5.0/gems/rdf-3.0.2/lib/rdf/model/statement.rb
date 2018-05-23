module RDF
  ##
  # An RDF statement.
  #
  # @example Creating an RDF statement
  #   s = RDF::URI.new("http://rubygems.org/gems/rdf")
  #   p = RDF::Vocab::DC.creator
  #   o = RDF::URI.new("http://ar.to/#self")
  #   RDF::Statement(s, p, o)
  #
  # @example Creating an RDF statement with a graph_name
  #   uri = RDF::URI("http://example/")
  #   RDF::Statement(s, p, o, graph_name: uri)
  #
  # @example Creating an RDF statement from a `Hash`
  #   RDF::Statement({
  #     subject:   RDF::URI.new("http://rubygems.org/gems/rdf"),
  #     predicate: RDF::Vocab::DC.creator,
  #     object:    RDF::URI.new("http://ar.to/#self"),
  #   })
  #
  # @example Creating an RDF statement with interned nodes
  #   RDF::Statement(:s, p, :o)
  #
  # @example Creating an RDF statement with a string
  #   RDF::Statement(s, p, "o")
  #
  class Statement
    include RDF::Value

    ##
    # @private
    # @since 0.2.2
    def self.from(statement, graph_name: nil, **options)
      case statement
        when Array, Query::Pattern
          graph_name ||= statement[3] == false ? nil : statement[3]
          self.new(statement[0], statement[1], statement[2], graph_name: graph_name, **options)
        when Statement then statement
        when Hash      then self.new(options.merge(statement))
        else raise ArgumentError, "expected RDF::Statement, Hash, or Array, but got #{statement.inspect}"
      end
    end

    # @return [Object]
    attr_accessor :id

    # @return [RDF::Resource]
    attr_accessor :graph_name

    # @return [RDF::Resource]
    attr_accessor :subject

    # @return [RDF::URI]
    attr_accessor :predicate

    # @return [RDF::Term]
    attr_accessor :object

    ##
    # @overload initialize(**options)
    #   @param  [Hash{Symbol => Object}] options
    #   @option options [RDF::Term]  :subject   (nil)
    #     A symbol is converted to an interned {Node}.
    #   @option options [RDF::URI]       :predicate (nil)
    #   @option options [RDF::Resource]      :object    (nil)
    #     if not a {Resource}, it is coerced to {Literal} or {Node} depending on if it is a symbol or something other than a {Term}.
    #   @option options [RDF::Term]  :graph_name   (nil)
    #     Note, in RDF 1.1, a graph name MUST be an {Resource}.
    #   @option options [Boolean] :inferred used as a marker to record that this statement was inferred based on semantic relationships (T-Box).
    #   @return [RDF::Statement]
    #
    # @overload initialize(subject, predicate, object, **options)
    #   @param  [RDF::Term]          subject
    #     A symbol is converted to an interned {Node}.
    #   @param  [RDF::URI]           predicate
    #   @param  [RDF::Resource]      object
    #     if not a {Resource}, it is coerced to {Literal} or {Node} depending on if it is a symbol or something other than a {Term}.
    #   @param  [Hash{Symbol => Object}] options
    #   @option options [RDF::Term]  :graph_name   (nil)
    #     Note, in RDF 1.1, a graph name MUST be an {Resource}.
    #   @option options [Boolean] :inferred used as a marker to record that this statement was inferred based on semantic relationships (T-Box).
    #   @return [RDF::Statement]
    def initialize(subject = nil, predicate = nil, object = nil, options = {})
      if subject.is_a?(Hash)
        @options   = Hash[subject] # faster subject.dup
        @subject   = @options.delete(:subject)
        @predicate = @options.delete(:predicate)
        @object    = @options.delete(:object)
      else
        @options   = !options.empty? ? Hash[options] : {}
        @subject   = subject
        @predicate = predicate
        @object    = object
      end
      @id          = @options.delete(:id) if @options.has_key?(:id)
      @graph_name  = @options.delete(:graph_name)
      initialize!
    end

    ##
    # @private
    def initialize!
      @graph_name   = Node.intern(@graph_name)   if @graph_name.is_a?(Symbol)
      @subject   = if @subject.is_a?(Value)
        @subject.to_term
      elsif @subject.is_a?(Symbol)
        Node.intern(@subject)
      elsif @subject.nil?
        nil
      else
        raise ArgumentError, "expected subject to be nil or a term, was #{@subject.inspect}"
      end
      @predicate = Node.intern(@predicate) if @predicate.is_a?(Symbol)
      @object    = if @object.is_a?(Value)
        @object.to_term
      elsif @object.is_a?(Symbol)
        Node.intern(@object)
      elsif @object.nil?
        nil
      else
        Literal.new(@object)
      end
    end

    ##
    # Returns `true` to indicate that this value is a statement.
    #
    # @return [Boolean]
    def statement?
      true
    end

    ##
    # Returns `true` if any element of the statement is not a
    # URI, Node or Literal.
    #
    # @return [Boolean]
    def variable?
      !(has_subject?    && subject.resource? &&
        has_predicate?  && predicate.resource? &&
        has_object?     && (object.resource? || object.literal?) &&
        (has_graph?     ? graph_name.resource? : true))
    end

    ##
    # @return [Boolean]
    def invalid?
      !valid?
    end

    ##
    # @return [Boolean]
    def valid?
      has_subject?    && subject.resource? && subject.valid? &&
      has_predicate?  && predicate.uri? && predicate.valid? &&
      has_object?     && object.term? && object.valid? &&
      (has_graph?      ? (graph_name.resource? && graph_name.valid?) : true)
    end

    ##
    # @return [Boolean]
    def asserted?
      !quoted?
    end

    ##
    # @return [Boolean]
    def quoted?
      false
    end

    ##
    # @return [Boolean]
    def inferred?
      !!@options[:inferred]
    end

    ##
    # Determines if the statement is incomplete, vs. invalid. An incomplete statement is one in which any of `subject`, `predicate`, or `object`, are nil.
    #
    # @return [Boolean]
    # @since 3.0
    def incomplete?
      to_triple.any?(&:nil?)
    end

    ##
    # Determines if the statement is complete, vs. invalid. A complete statement is one in which none of `subject`, `predicate`, or `object`, are nil.
    #
    # @return [Boolean]
    # @since 3.0
    def complete?
      !incomplete?
    end

    ##
    # @return [Boolean]
    def has_graph?
      !!graph_name
    end
    alias_method :has_name?, :has_graph?

    ##
    # @return [Boolean]
    def has_subject?
      !!subject
    end

    ##
    # @return [Boolean]
    def has_predicate?
      !!predicate
    end

    ##
    # @return [Boolean]
    def has_object?
      !!object
    end

    ##
    # Returns `true` if any resource of this statement is a blank node.
    #
    # @return [Boolean]
    # @since 2.0
    def node?
      to_quad.compact.any?(&:node?)
    end
    alias_method :has_blank_nodes?, :node?

    ##
    # Checks statement equality as a quad.
    #
    # @param  [Statement] other
    # @return [Boolean]
    #
    # @see RDF::URI#==
    # @see RDF::Node#==
    # @see RDF::Literal#==
    # @see RDF::Query::Variable#==
    def eql?(other)
      other.is_a?(Statement) && self == other && (self.graph_name || false) == (other.graph_name || false)
    end

    ##
    # Generates a Integer hash value as a quad.
    def hash
      @hash ||= to_quad.hash
    end

    ##
    # Checks statement equality as a triple.
    #
    # @param  [Object] other
    # @return [Boolean]
    #
    # @see RDF::URI#==
    # @see RDF::Node#==
    # @see RDF::Literal#==
    # @see RDF::Query::Variable#==
    def ==(other)
      to_a == Array(other) &&
        !(other.is_a?(RDF::Value) && other.list?)
    end

    ##
    # Checks statement equality with patterns.
    #
    # Uses `#eql?` to compare each of `#subject`, `#predicate`, `#object`, and
    # `#graph_name` to those of `other`. Any statement part which is not
    # present in `self` is ignored.
    #
    # @example
    #   statement = RDF::Statement.new(RDF::URI('s'), RDF::URI('p'), RDF::URI('o'))
    #   pattern   = RDF::Statement.new(RDF::URI('s'), RDF::URI('p'), RDF::Query::Variable.new)
    #
    #   # true
    #   statement === statement
    #   pattern   === statement
    #   RDF::Statement.new(nil, nil, nil) === statement
    #
    #   # false
    #   statement === pattern
    #   statement === RDF::Statement.new(nil, nil, nil)
    #
    # @param  [Statement] other
    # @return [Boolean]
    #
    # @see RDF::URI#eql?
    # @see RDF::Node#eql?
    # @see RDF::Literal#eql?
    # @see RDF::Query::Variable#eql?
    def ===(other)
      return false if has_object?    && !object.eql?(other.object)
      return false if has_predicate? && !predicate.eql?(other.predicate)
      return false if has_subject?   && !subject.eql?(other.subject)
      return false if has_graph?     && !graph_name.eql?(other.graph_name)
      return true
    end

    ##
    # @param  [Integer] index
    # @return [RDF::Term]
    def [](index)
      case index
        when 0 then self.subject
        when 1 then self.predicate
        when 2 then self.object
        when 3 then self.graph_name
        else nil
      end
    end

    ##
    # @param  [Integer]    index
    # @param  [RDF::Term] value
    # @return [RDF::Term]
    def []=(index, value)
      case index
        when 0 then self.subject   = value
        when 1 then self.predicate = value
        when 2 then self.object    = value
        when 3 then self.graph_name   = value
        else nil
      end
    end

    ##
    # @return [Array(RDF::Term)]
    def to_quad
      [subject, predicate, object, graph_name]
    end

    ##
    # @return [Array(RDF::Term)]
    def to_triple
      [subject, predicate, object]
    end
    alias_method :to_a, :to_triple

    ##
    # Canonicalizes each unfrozen term in the statement
    #
    # @return [RDF::Statement] `self`
    # @since  1.0.8
    # @raise [ArgumentError] if any element cannot be canonicalized.
    def canonicalize!
      self.subject.canonicalize!    if has_subject? && !self.subject.frozen?
      self.predicate.canonicalize!  if has_predicate? && !self.predicate.frozen?
      self.object.canonicalize!     if has_object? && !self.object.frozen?
      self.graph_name.canonicalize! if has_graph? && !self.graph_name.frozen?
      self.validate!
      @hash = nil
      self
    end

    ##
    # Returns a version of the statement with each position in canonical form
    #
    # @return [RDF::Statement] `self` or nil if statement cannot be canonicalized
    # @since  1.0.8
    def canonicalize
      self.dup.canonicalize!
    rescue ArgumentError
      nil
    end

    ##
    # Returns the terms of this statement as a `Hash`.
    #
    # @param  [Symbol] subject_key
    # @param  [Symbol] predicate_key
    # @param  [Symbol] object_key
    # @return [Hash{Symbol => RDF::Term}]
    def to_h(subject_key = :subject, predicate_key = :predicate, object_key = :object, graph_key = :graph_name)
      {subject_key => subject, predicate_key => predicate, object_key => object, graph_key => graph_name}
    end

    ##
    # Returns a string representation of this statement.
    #
    # @return [String]
    def to_s
      (graph_name ? to_quad : to_triple).map do |term|
        term.respond_to?(:to_base) ? term.to_base : term.inspect
      end.join(" ") + " ."
    end

    ##
    # Returns a graph containing this statement in reified form.
    #
    # @param [RDF::Term]  subject   (nil)
    #   Subject of reification.
    # @param [RDF::Term]  id   (nil)
    #   Node identifier, when subject is anonymous
    # @param [RDF::Term]  graph_name   (nil)
    #   Note, in RDF 1.1, a graph name MUST be an {Resource}.
    # @return [RDF::Graph]
    # @see    http://www.w3.org/TR/rdf-primer/#reification
    def reified(subject: nil, id: nil, graph_name: nil)
      RDF::Graph.new(graph_name: graph_name) do |graph|
        subject = subject || RDF::Node.new(id)
        graph << [subject, RDF.type,      RDF[:Statement]]
        graph << [subject, RDF.subject,   self.subject]
        graph << [subject, RDF.predicate, self.predicate]
        graph << [subject, RDF.object,    self.object]
      end
    end
  end
end
