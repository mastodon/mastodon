module RDF
  ##
  # An RDF statement enumeration mixin.
  #
  # Classes that include this module must implement an `#each` method that
  # yields {RDF::Statement RDF statements}.
  #
  # @example Checking whether any statements exist
  #   enumerable.empty?
  #
  # @example Checking how many statements exist
  #   enumerable.count
  #
  # @example Checking whether a specific statement exists
  #   enumerable.has_statement?(RDF::Statement(subject, predicate, object))
  #   enumerable.has_triple?([subject, predicate, object])
  #   enumerable.has_quad?([subject, predicate, object, graph_name])
  #
  # @example Checking whether a specific value exists
  #   enumerable.has_subject?(RDF::URI("http://rubygems.org/gems/rdf"))
  #   enumerable.has_predicate?(RDF::RDFS.label)
  #   enumerable.has_object?(RDF::Literal("A Ruby library for working with Resource Description Framework (RDF) data.", language: :en))
  #   enumerable.has_graph?(RDF::URI("http://ar.to/#self"))
  #
  # @example Enumerating all statements
  #   enumerable.each_statement do |statement|
  #     puts statement.inspect
  #   end
  #
  # @example Enumerating all statements in the form of triples
  #   enumerable.each_triple do |subject, predicate, object|
  #     puts [subject, predicate, object].inspect
  #   end
  #
  # @example Enumerating all statements in the form of quads
  #   enumerable.each_quad do |subject, predicate, object, graph_name|
  #     puts [subject, predicate, object, graph_name].inspect
  #   end
  #
  # @example Enumerating all terms
  #   enumerable.each_subject   { |term| puts term.inspect }
  #   enumerable.each_predicate { |term| puts term.inspect }
  #   enumerable.each_object    { |term| puts term.inspect }
  #   enumerable.each_term      { |term| puts term.inspect }
  #
  # @example Obtaining all statements
  #   enumerable.statements  #=> [RDF::Statement(subject1, predicate1, object1), ...]
  #   enumerable.triples     #=> [[subject1, predicate1, object1], ...]
  #   enumerable.quads       #=> [[subject1, predicate1, object1, graph_name1], ...]
  #
  # @example Obtaining all unique values
  #   enumerable.subjects(unique: true)    #=> [subject1, subject2, subject3, ...]
  #   enumerable.predicates(unique: true)  #=> [predicate1, predicate2, predicate3, ...]
  #   enumerable.objects(unique: true)     #=> [object1, object2, object3, ...]
  #   enumerable.graph_names(unique: true) #=> [graph_name1, graph_name2, graph_name3, ...]
  #
  # @see RDF::Graph
  # @see RDF::Repository
  module Enumerable
    autoload :Enumerator, 'rdf/mixin/enumerator'
    extend  RDF::Util::Aliasing::LateBound
    include ::Enumerable
    include RDF::Countable # NOTE: must come after ::Enumerable

    ##
    # Returns `true` if this enumerable supports the given `feature`.
    #
    # Supported features include:
    #   * `:graph_name` supports statements with a graph_name, allowing multiple named graphs
    #   * `:inference` supports RDFS inferrence of queryable contents.
    #   * `:literal_equality' preserves [term-equality](https://www.w3.org/TR/rdf11-concepts/#dfn-literal-term-equality) for literals. Literals are equal only if their lexical values and datatypes are equal, character by character. Literals may be "inlined" to value-space for efficiency only if `:literal_equality` is `false`.
    #   * `:validity` allows a concrete Enumerable implementation to indicate that it does or does not support valididty checking. By default implementations are assumed to support validity checking.
    #   * `:skolemize` supports [Skolemization](https://www.w3.org/wiki/BnodeSkolemization) of an `Enumerable`. Implementations supporting this feature must implement a `#skolemize` method, taking a base URI used for minting URIs for BNodes as stable identifiers and a `#deskolemize` method, also taking a base URI used for turning URIs having that prefix back into the same BNodes which were originally skolemized.
    #
    # @param  [Symbol, #to_sym] feature
    # @return [Boolean]
    # @since  0.3.5
    def supports?(feature)
      feature == :validity || feature == :literal_equality
    end

    ##
    # Returns `true` if all statements are valid
    #
    # @return [Boolean] `true` or `false`
    # @raise  [NotImplementedError] unless enumerable supports validation
    # @since  0.3.11
    def valid?
      raise NotImplementedError, "#{self.class} does not support validation" unless supports?(:validity)
      each_statement do |s|
        return false if s.invalid?
      end
      true
    end

    ##
    # Returns `true` if value is not valid
    #
    # @return [Boolean] `true` or `false`
    # @raise  [NotImplementedError] unless enumerable supports validation
    # @since  0.2.1
    def invalid?
      !valid?
    end

    ##
    # Default validate! implementation, overridden in concrete classes
    # @return [RDF::Enumerable] `self`
    # @raise  [ArgumentError] if the value is invalid
    # @since  0.3.9
    def validate!
      raise ArgumentError if supports?(:validity) && invalid?
      self
    end
    alias_method :validate, :validate!

    ##
    # Returns all RDF statements.
    #
    # @param  [Hash{Symbol => Boolean}] options
    # @return [Array<RDF::Statement>]
    # @see    #each_statement
    # @see    #enum_statement
    def statements(**options)
      enum_statement.to_a
    end

    ##
    # Returns `true` if `self` contains the given RDF statement.
    #
    # @param  [RDF::Statement] statement
    # @return [Boolean]
    def has_statement?(statement)
      !enum_statement.find { |s| s.eql?(statement) }.nil?
    end
    alias_method :include?, :has_statement?

    ##
    # Iterates the given block for each RDF statement.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which statements are yielded is undefined.
    #
    # @overload each_statement
    #   @yield  [statement]
    #     each statement
    #   @yieldparam  [RDF::Statement] statement
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_statement
    #   @return [Enumerator<RDF::Statement>]
    #
    # @see    #enum_statement
    def each_statement(&block)
      if block_given?
        # Invoke {#each} in the containing class:
        each(&block)
      end
      enum_statement
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_statement}.
    # FIXME: enum_for doesn't seem to be working properly
    # in JRuby 1.7, so specs are marked pending
    #
    # @return [Enumerator<RDF::Statement>]
    # @see    #each_statement
    def enum_statement
      # Ensure that statements are queryable, countable and enumerable
      this = self
      Queryable::Enumerator.new do |yielder|
        this.send(:each_statement) {|y| yielder << y}
      end
    end
    alias_method :enum_statements, :enum_statement

    ##
    # Returns all RDF triples.
    #
    # @param  [Hash{Symbol => Boolean}] options
    # @return [Array<Array(RDF::Resource, RDF::URI, RDF::Term)>]
    # @see    #each_triple
    # @see    #enum_triple
    def triples(**options)
      enum_statement.map(&:to_triple) # TODO: optimize
    end

    ##
    # Returns `true` if `self` contains the given RDF triple.
    #
    # @param  [Array(RDF::Resource, RDF::URI, RDF::Term)] triple
    # @return [Boolean]
    def has_triple?(triple)
      triples.include?(triple)
    end

    ##
    # Iterates the given block for each RDF triple.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which triples are yielded is undefined.
    #
    # @overload each_triple
    #   @yield  [subject, predicate, object]
    #     each triple
    #   @yieldparam  [RDF::Resource] subject
    #   @yieldparam  [RDF::URI]      predicate
    #   @yieldparam  [RDF::Term]     object
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_triple
    #   @return [Enumerator<Array(RDF::Resource, RDF::URI, RDF::Term)>]
    #
    # @see    #enum_triple
    def each_triple
      if block_given?
        each_statement do |statement|
          yield *statement.to_triple
        end
      end
      enum_triple
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_triple}.
    #
    # @return [Enumerator<Array(RDF::Resource, RDF::URI, RDF::Term)>]
    # @see    #each_triple
    def enum_triple
      Countable::Enumerator.new do |yielder|
        each_triple {|s, p, o| yielder << [s, p, o]}
      end
    end
    alias_method :enum_triples, :enum_triple

    ##
    # Returns all RDF quads.
    #
    # @param  [Hash{Symbol => Boolean}] options
    # @return [Array<Array(RDF::Resource, RDF::URI, RDF::Term, RDF::Resource)>]
    # @see    #each_quad
    # @see    #enum_quad
    def quads(**options)
      enum_statement.map(&:to_quad) # TODO: optimize
    end

    ##
    # Returns `true` if `self` contains the given RDF quad.
    #
    # @param  [Array(RDF::Resource, RDF::URI, RDF::Term, RDF::Resource)] quad
    # @return [Boolean]
    def has_quad?(quad)
      quads.include?(quad)
    end

    ##
    # Iterates the given block for each RDF quad.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which quads are yielded is undefined.
    #
    # @overload each_quad
    #   @yield  [subject, predicate, object, graph_name]
    #     each quad
    #   @yieldparam [RDF::Resource] subject
    #   @yieldparam [RDF::URI]      predicate
    #   @yieldparam [RDF::Term]     object
    #   @yieldparam [RDF::Resource] graph_name
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_quad
    #   @return [Enumerator<Array(RDF::Resource, RDF::URI, RDF::Term, RDF::Resource)>]
    #
    # @see    #enum_quad
    def each_quad
      if block_given?
        each_statement do |statement|
          yield *statement.to_quad
        end
      end
      enum_quad
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_quad}.
    #
    # @return [Enumerator<Array(RDF::Resource, RDF::URI, RDF::Term, RDF::Resource)>]
    # @see    #each_quad
    def enum_quad
      Countable::Enumerator.new do |yielder|
        each_quad {|s, p, o, c| yielder << [s, p, o, c]}
      end
    end
    alias_method :enum_quads, :enum_quad

    ##
    # Returns all unique RDF subject terms.
    #
    # @param  unique (true)
    # @return [Array<RDF::Resource>]
    # @see    #each_subject
    # @see    #enum_subject
    def subjects(unique: true)
      unless unique
        enum_statement.map(&:subject) # TODO: optimize
      else
        enum_subject.to_a
      end
    end

    ##
    # Returns `true` if `self` contains the given RDF subject term.
    #
    # @param  [RDF::Resource] value
    # @return [Boolean]
    def has_subject?(value)
      enum_subject.include?(value)
    end

    ##
    # Iterates the given block for each unique RDF subject term.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which values are yielded is undefined.
    #
    # @overload each_subject
    #   @yield  [subject]
    #     each subject term
    #   @yieldparam  [RDF::Resource] subject
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_subject
    #   @return [Enumerator<RDF::Resource>]
    # @see    #enum_subject
    def each_subject
      if block_given?
        values = {}
        each_statement do |statement|
          value = statement.subject
          unless value.nil? || values.include?(value.to_s)
            values[value.to_s] = true
            yield value
          end
        end
      end
      enum_subject
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_subject}.
    #
    # @return [Enumerator<RDF::Resource>]
    # @see    #each_subject
    def enum_subject
      enum_for(:each_subject)
    end
    alias_method :enum_subjects, :enum_subject

    ##
    # Returns all unique RDF predicate terms.
    #
    # @param  unique (true)
    # @return [Array<RDF::URI>]
    # @see    #each_predicate
    # @see    #enum_predicate
    def predicates(unique: true)
      unless unique
        enum_statement.map(&:predicate) # TODO: optimize
      else
        enum_predicate.to_a
      end
    end

    ##
    # Returns `true` if `self` contains the given RDF predicate term.
    #
    # @param  [RDF::URI] value
    # @return [Boolean]
    def has_predicate?(value)
      enum_predicate.include?(value)
    end

    ##
    # Iterates the given block for each unique RDF predicate term.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which values are yielded is undefined.
    #
    # @overload each_predicate
    #   @yield  [predicate]
    #     each predicate term
    #   @yieldparam  [RDF::URI] predicate
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_predicate
    #   @return [Enumerator<RDF::URI>]
    # @see    #enum_predicate
    def each_predicate
      if block_given?
        values = {}
        each_statement do |statement|
          value = statement.predicate
          unless value.nil? || values.include?(value.to_s)
            values[value.to_s] = true
            yield value
          end
        end
      end
      enum_predicate
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_predicate}.
    #
    # @return [Enumerator<RDF::URI>]
    # @see    #each_predicate
    def enum_predicate
      enum_for(:each_predicate)
    end
    alias_method :enum_predicates, :enum_predicate

    ##
    # Returns all unique RDF object terms.
    #
    # @param  unique (true)
    # @return [Array<RDF::Term>]
    # @see    #each_object
    # @see    #enum_object
    def objects(unique: true)
      unless unique
        enum_statement.map(&:object) # TODO: optimize
      else
        enum_object.to_a
      end
    end

    ##
    # Returns `true` if `self` contains the given RDF object term.
    #
    # @param  [RDF::Term] value
    # @return [Boolean]
    def has_object?(value)
      enum_object.include?(value)
    end

    ##
    # Iterates the given block for each unique RDF object term.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which values are yielded is undefined.
    #
    # @overload each_object
    #   @yield  [object]
    #     each object term
    #   @yieldparam  [RDF::Term] object
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_object
    #   @return [Enumerator<RDF::Term>]
    #
    # @see    #enum_object
    def each_object # FIXME: deduplication
      if block_given?
        values = {}
        each_statement do |statement|
          value = statement.object
          unless value.nil? || values.include?(value)
            values[value] = true
            yield value
          end
        end
      end
      enum_object
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_object}.
    #
    # @return [Enumerator<RDF::Term>]
    # @see    #each_object
    def enum_object
      enum_for(:each_object)
    end
    alias_method :enum_objects, :enum_object

    ##
    # Returns all unique RDF terms (subjects, predicates, objects, and graph_names).
    #
    # @example finding all Blank Nodes used within an enumerable
    #   enumberable.terms.select(&:node?)
    #
    # @param  unique (true)
    # @return [Array<RDF::Resource>]
    # @since 2.0
    # @see    #each_resource
    # @see    #enum_resource
    def terms(unique: true)
      unless unique
        enum_statement.
          map(&:to_quad).
          flatten.
          compact
      else
        enum_term.to_a
      end
    end

    ##
    # Returns `true` if `self` contains the given RDF subject term.
    #
    # @param  [RDF::Resource] value
    # @return [Boolean]
    # @since 2.0
    def has_term?(value)
      enum_term.include?(value)
    end

    ##
    # Iterates the given block for each unique RDF term (subject, predicate, object, or graph_name).
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which values are yielded is undefined.
    #
    # @overload each_term
    #   @yield  [term]
    #     each term
    #   @yieldparam  [RDF::Term] term
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_term
    #   @return [Enumerator<RDF::Term>]
    # @since 2.0
    # @see    #enum_term
    def each_term
      if block_given?
        values = {}
        each_statement do |statement|
          statement.to_quad.each do |value|
            unless value.nil? || values.include?(value.hash)
              values[value.hash] = true
              yield value
            end
          end
        end
      end
      enum_term
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_term}.
    #
    # @return [Enumerator<RDF::Term>]
    # @see    #each_term
    # @since 2.0
    def enum_term
      enum_for(:each_term)
    end
    alias_method :enum_terms, :enum_term

    ##
    # Returns all unique RDF graph names, other than the default graph.
    #
    # @param  unique (true)
    # @return [Array<RDF::Resource>]
    # @see    #each_graph
    # @see    #enum_graph
    # @since 2.0
    def graph_names(unique: true)
      unless unique
        enum_statement.map(&:graph_name).compact # TODO: optimize
      else
        enum_graph.map(&:graph_name).compact
      end
    end

    ##
    # Returns `true` if `self` contains the given RDF graph_name.
    #
    # @param  [RDF::Resource, false] graph_name
    #   Use value `false` to query for the default graph_name
    # @return [Boolean]
    def has_graph?(graph_name)
      enum_statement.any? {|s| s.graph_name == graph_name}
    end

    ##
    # Limits statements to be from a specific graph.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which statements are yielded is undefined.
    #
    # @overload project_graph(graph_name)
    #   @param [RDF::Resource, nil] graph_name
    #     The name of the graph from which statements are taken.
    #     Use `nil` for the default graph.
    #   @yield  [statement]
    #     each statement
    #   @yieldparam  [RDF::Statement] statement
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload project_graph(graph_name)
    #   @param [RDF::Resource, false] graph_name
    #     The name of the graph from which statements are taken.
    #     Use `false` for the default graph.
    #   @return [Enumerable]
    #
    # @see    #each_statement
    # @since 3.0
    def project_graph(graph_name)
      if block_given?
        self.each do |statement|
          yield statement if statement.graph_name == graph_name
        end
      else
        # Ensure that statements are queryable, countable and enumerable
        this = self
        Queryable::Enumerator.new do |yielder|
          this.send(:project_graph, graph_name) {|y| yielder << y}
        end
      end
    end

    ##
    # Iterates the given block for each RDF graph in `self`.
    #
    # If no block was given, returns an enumerator.
    #
    # The order in which graphs are yielded is undefined.
    #
    # @overload each_graph
    #   @yield  [graph]
    #     each graph
    #   @yieldparam  [RDF::Graph] graph
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_graph
    #   @return [Enumerator<RDF::Graph>]
    #
    # @see    #enum_graph
    # @since  0.1.9
    def each_graph
      if block_given?
        yield RDF::Graph.new(graph_name: nil, data: self)
        # FIXME: brute force, repositories should override behavior
        if supports?(:graph_name)
          enum_statement.map(&:graph_name).uniq.compact.each do |graph_name|
            yield RDF::Graph.new(graph_name: graph_name, data: self)
          end
        end
      end
      enum_graph
    end

    ##
    # Returns an enumerator for {RDF::Enumerable#each_graph}.
    #
    # @return [Enumerator<RDF::Graph>]
    # @see    #each_graph
    # @since  0.1.9
    def enum_graph
      enum_for(:each_graph)
    end
    alias_method :enum_graphs, :enum_graph

    ##
    # Returns all RDF statements in `self` as an array.
    #
    # Mixes in `RDF::Enumerable` into the returned object.
    #
    # @return [Array]
    # @since  0.2.0
    def to_a
      super.extend(RDF::Enumerable)
    end

    ##
    # Returns all RDF statements in `self` as a set.
    #
    # Mixes in `RDF::Enumerable` into the returned object.
    #
    # @return [Set]
    # @since  0.2.0
    def to_set
      require 'set' unless defined?(::Set)
      super.extend(RDF::Enumerable)
    end

    ##
    # Returns all RDF object terms indexed by their subject and predicate
    # terms.
    #
    # The return value is a `Hash` instance that has the structure:
    # `{subject => {predicate => [*objects]}}`.
    #
    # @return [Hash]
    def to_h
      result = {}
      each_statement do |statement|
        result[statement.subject] ||= {}
        values = (result[statement.subject][statement.predicate] ||= [])
        values << statement.object unless values.include?(statement.object)
      end
      result
    end

    ##
    # Returns a serialized string representation of `self`.
    #
    # Before calling this method you may need to explicitly require a
    # serialization extension for the specified format.
    #
    # @example Serializing into N-Triples format
    #   require 'rdf/ntriples'
    #   ntriples = enumerable.dump(:ntriples)
    #
    # @param  [Array<Object>] args
    #   if the last argument is a hash, it is passed as options to
    #   {RDF::Writer.dump}.
    # @return [String]
    # @see    RDF::Writer.dump
    # @raise [RDF::WriterError] if no writer found
    # @since  0.2.0
    def dump(*args, **options)
      writer = RDF::Writer.for(*args)
      raise RDF::WriterError, "No writer found using #{args.inspect}" unless writer
      writer.dump(self, nil, **options)
    end

  protected

    ##
    # @overload #to_writer
    #   Implements #to_writer for each available instance of {RDF::Writer},
    #   based on the writer symbol.
    #
    #   @return [String]
    #   @see {RDF::Writer.sym}
    def method_missing(meth, *args)
      writer = RDF::Writer.for(meth.to_s[3..-1].to_sym) if meth.to_s[0,3] == "to_"
      if writer
        writer.buffer(standard_prefixes: true) {|w| w << self}
      else
        super
      end
    end

    ##
    # @note this instantiates an writer; it could probably be done more
    #   efficiently by refactoring `RDF::Reader` and/or `RDF::Format` to expose
    #   a list of valid format symbols.
    def respond_to_missing?(name, include_private = false)
      return RDF::Writer.for(name.to_s[3..-1].to_sym) if name.to_s[0,3] == 'to_'
      super
    end

    ##
    # @private
    # @param  [Symbol, #to_sym] method
    # @return [Enumerator]
    # @see    Object#enum_for
    def enum_for(method = :each, *args)
      # Ensure that enumerators are, themselves, queryable
      this = self
      Enumerable::Enumerator.new do |yielder|
        this.send(method, *args) {|*y| yielder << (y.length > 1 ? y : y.first)}
      end
    end
    alias_method :to_enum, :enum_for
  end # Enumerable
end # RDF
