module RDF
  ##
  # An RDF graph.
  #
  # An {RDF::Graph} contains a unique set of {RDF::Statement}. It is
  # based on an underlying data object, which may be specified when the
  # graph is initialized, and will default to a {RDF::Repository} without
  # support for named graphs otherwise.
  #
  # Note that in RDF 1.1, graphs are not named, but are associated with
  # a graph name in a Dataset, as a pair of <name, graph>.
  # This class allows a name to be associated with a graph when it is
  # a projection of an underlying {RDF::Repository} supporting graph_names.
  #
  # @example Creating an empty unnamed graph
  #   graph = RDF::Graph.new
  #
  # @example Loading graph data from a URL
  #   graph = RDF::Graph.load("http://ruby-rdf.github.io/rdf/etc/doap.nt")
  #
  # @example Loading graph data from a URL
  #   require 'rdf/rdfxml'  # for RDF/XML support
  #   
  #   graph = RDF::Graph.load("http://www.bbc.co.uk/programmes/b0081dq5.rdf")
  #
  # @example Accessing a specific named graph within a {RDF::Repository}
  #   require 'rdf/trig'  # for TriG support
  #
  #   repository = graph = RDF::Repository.load("https://raw.githubusercontent.com/ruby-rdf/rdf-trig/develop/etc/doap.trig", format: :trig))
  #   graph = RDF::Graph.new(graph_name: RDF::URI("http://greggkellogg.net/foaf#me"), data: repository)
  class Graph
    include RDF::Value
    include RDF::Countable
    include RDF::Durable
    include RDF::Enumerable
    include RDF::Queryable
    include RDF::Mutable
    include RDF::Transactable

    ##
    # Returns the options passed to this graph when it was constructed.
    #
    # @!attribute [r] options
    # @return [Hash{Symbol => Object}]
    attr_reader :options

    ##
    # Name of this graph, if it is part of an {RDF::Repository}
    # @!attribute [rw] graph_name
    # @return [RDF::Resource]
    # @since 1.1.18
    attr_accessor :graph_name

    alias_method :name, :graph_name
    alias_method :name=, :graph_name=

    ##
    # {RDF::Queryable} backing this graph.
    # @!attribute [rw] data
    # @return [RDF::Queryable]
    attr_accessor :data

    ##
    # Creates a new `Graph` instance populated by the RDF data returned by
    # dereferencing the given graph_name Resource.
    #
    # @param  [String, #to_s] url
    # @param  [RDF::Resource] graph_name
    #   Set set graph name of each loaded statement
    # @param  [Hash{Symbol => Object}] options
    #   Options from {RDF::Reader.open}
    # @yield  [graph]
    # @yieldparam [Graph] graph
    # @return [Graph]
    # @since  0.1.7
    def self.load(url, graph_name: nil, **options, &block)
      self.new(graph_name: graph_name, **options) do |graph|
        graph.load(url, graph_name: graph_name, **options)

        if block_given?
          case block.arity
            when 1 then block.call(graph)
            else graph.instance_eval(&block)
          end
        end
      end
    end

    ##
    # @param  [RDF::Resource] graph_name
    #   The graph_name from the associated {RDF::Queryable} associated
    #   with this graph as provided with the `:data` option
    #   (only for {RDF::Queryable} instances supporting
    #   named graphs).
    # @param [RDF::Queryable] data (RDF::Repository.new)
    #   Storage behind this graph.
    #
    # @raise [ArgumentError] if a `data` does not support named graphs.
    # @note
    #   Graph names are only useful when used as a projection
    #   on a `:data` which supports named graphs. Otherwise, there is no
    #   such thing as a named graph in RDF 1.1, a repository may have
    #   graphs which are named, but the name is not a property of the graph.
    # @yield  [graph]
    # @yieldparam [Graph]
    def initialize(graph_name: nil, data: nil, **options, &block)
      @graph_name = case graph_name
        when nil then nil
        when RDF::Resource then graph_name
        else RDF::URI.new(graph_name)
      end

      @options = options.dup
      @data = data || RDF::Repository.new(with_graph_name: false)

      raise ArgumentError, "Can't apply graph_name unless initialized with `data` supporting graph_names" if
        @graph_name && !@data.supports?(:graph_name)

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else instance_eval(&block)
        end
      end
    end

    ##
    # (re)loads the graph from the specified location, or from the location associated with the graph name, if any
    # @return [void]
    # @see    RDF::Mutable#load
    def load!(*args)
      case
        when args.empty?
          raise ArgumentError, "Can't reload graph without a graph_name" unless graph_name.is_a?(RDF::URI)
          load(graph_name.to_s, base_uri: graph_name)
        else super
      end
    end

    ##
    # Returns `true` to indicate that this is a graph.
    #
    # @return [Boolean]
    def graph?
      true
    end

    ##
    # Returns `true` if this is a named graph.
    #
    # @return [Boolean]
    # @note The next release, graphs will not be named, this will return false
    def named?
      !unnamed?
    end

    ##
    # Returns `true` if this is a unnamed graph.
    #
    # @return [Boolean]
    # @note The next release, graphs will not be named, this will return true
    def unnamed?
      graph_name.nil?
    end

    ##
    # A graph is durable if it's underlying data model is durable
    #
    # @return [Boolean]
    # @see    RDF::Durable#durable?
    def durable?
      @data.durable?
    end

    ##
    # Returns all unique RDF names for this graph.
    #
    # @return [Enumerator<RDF::Resource>]
    def graph_names(unique: true)
      (named? ? [graph_name] : []).extend(RDF::Countable)
    end

    ##
    # Returns the {RDF::Resource} representation of this graph.
    #
    # @return [RDF::Resource]
    def to_uri
      graph_name
    end

    ##
    # Returns a string representation of this graph.
    #
    # @return [String]
    def to_s
      named? ? graph_name.to_s : "default"
    end

    ##
    # Returns `true` if this graph has an anonymous graph, `false` otherwise.
    #
    # @return [Boolean]
    # @note The next release, graphs will not be named, this will return true
    def anonymous?
      graph_name.nil? ? false : graph_name.anonymous?
    end

    ##
    # Returns the number of RDF statements in this graph.
    #
    # @return [Integer]
    # @see    RDF::Enumerable#count
    def count
      @data.query(graph_name: graph_name || false).count
    end

    ##
    # Returns `true` if this graph contains the given RDF statement.
    #
    # A statement is in a graph if the statement if it has the same triples without regard to graph_name.
    #
    # @param  [Statement] statement
    # @return [Boolean]
    # @see    RDF::Enumerable#has_statement?
    def has_statement?(statement)
      statement = statement.dup
      statement.graph_name = graph_name
      @data.has_statement?(statement)
    end

    ##
    # Enumerates each RDF statement in this graph.
    #
    # @yield  [statement]
    # @yieldparam [Statement] statement
    # @return [Enumerator]
    # @see    RDF::Enumerable#each_statement
    def each(&block)
      if @data.respond_to?(:query)
        @data.query(graph_name: graph_name || false, &block)
      elsif @data.respond_to?(:each)
        @data.each(&block)
      else
        @data.to_a.each(&block)
      end
    end

    ##
    # @private
    # @see RDF::Enumerable#project_graph
    def project_graph(graph_name, &block)
      if block_given?
        self.each(&block) if graph_name == self.graph_name
      else
        graph_name == self.graph_name ? self : RDF::Graph.new
      end
    end

    ##
    # Graph equivalence based on the contents of each graph being _exactly_
    # the same. To determine if the have the same _meaning_, consider
    # [rdf-isomorphic](http://rubygems.org/gems/rdf-isomorphic).
    #
    # @param [RDF::Graph] other
    # @return [Boolean]
    # @see http://rubygems.org/gems/rdf-isomorphic
    def ==(other)
      other.is_a?(RDF::Graph) &&
      graph_name == other.graph_name &&
      statements.to_a == other.statements.to_a
    end

    ##
    # @private
    # @see RDF::Queryable#query_pattern
    def query_pattern(pattern, **options, &block)
      pattern = pattern.dup
      pattern.graph_name = graph_name || false
      @data.query(pattern, &block)
    end

    ##
    # @private
    # @see RDF::Mutable#insert
    def insert_statement(statement)
      statement = statement.dup
      statement.graph_name = graph_name
      @data.insert(statement)
    end

    ##
    # @private
    # @see RDF::Mutable#insert_statements
    def insert_statements(statements)
      enum = Enumerable::Enumerator.new do |yielder|
        
        statements.send(statements.respond_to?(:each_statement) ? :each_statement : :each) do |s|
          s = s.dup
          s.graph_name = graph_name
          yielder << s
        end
      end
      @data.insert(enum)
    end

    ##
    # @private
    # @see RDF::Mutable#delete
    def delete_statement(statement)
      statement = statement.dup
      statement.graph_name = graph_name
      @data.delete(statement)
    end

    ##
    # @private
    # @see RDF::Mutable#clear
    def clear_statements
      @data.delete(graph_name: graph_name || false)
    end

    ##
    # @private
    # Opens a transaction over the graph
    # @see RDF::Transactable#begin_transaction
    def begin_transaction(mutable: false, graph_name: @graph_name)
      @data.send(:begin_transaction, mutable: mutable, graph_name: graph_name)
    end

    protected :query_pattern
    protected :insert_statement
    protected :delete_statement
    protected :clear_statements
    protected :begin_transaction

    ##
    # @private
    # @see    RDF::Enumerable#graphs
    # @since  0.2.0
    def graphs
      Array(enum_graph)
    end

    ##
    # @private
    # @see    RDF::Enumerable#each_graph
    # @since  0.2.0
    def each_graph
      if block_given?
        yield self
      else
        enum_graph
      end
    end
  end
end
