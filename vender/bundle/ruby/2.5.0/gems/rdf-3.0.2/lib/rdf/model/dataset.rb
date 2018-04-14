module RDF
  ##
  # An RDF Dataset
  #
  # Datasets are immutable by default. {RDF::Repository} provides an interface
  # for mutable Datasets.
  #
  # A Dataset functions as an a set of named RDF graphs with a default graph.
  # It implements {RDF::Enumerable} and {RDF::Queryable} over the whole set;
  # if no specific graph name is queried, enumerating and querying takes place
  # over the intersection of all the graphs in the Dataset.
  #
  # The default graph is named with a constant `DEFAULT_GRAPH`.
  #
  # @example initializing an RDF::Dataset with existing data
  #   statements = [RDF::Statement.new(RDF::URI(:s), RDF::URI(:p), :o)]
  #   dataset    = RDF::Dataset.new(statements: statements)
  #   dataset.count # => 1
  #
  # @see https://www.w3.org/TR/rdf11-concepts/#section-dataset
  # @see https://www.w3.org/TR/rdf11-datasets/
  class Dataset
    include RDF::Enumerable
    include RDF::Durable
    include RDF::Queryable

    DEFAULT_GRAPH = false

    ISOLATION_LEVELS = [ :read_uncommitted,
                         :read_committed,
                         :repeatable_read,
                         :snapshot,
                         :serializable ].freeze

    ##
    # @param [RDF::Enumerable, Array<RDF::Statement>] statements  the initial 
    #   contents of the dataset
    # @yield [dataset] yields itself when a block is given
    # @yieldparam [RDF::Dataset] dataset
    def initialize(statements: [], **options, &block)
      @statements = statements.map do |s| 
        s = s.dup
        s.graph_name ||= DEFAULT_GRAPH
        s.freeze
      end.freeze

      if block_given?
        case block.arity
          when 1 then yield self
          else instance_eval(&block)
        end
      end
    end

    ##
    # @private
    # @see RDF::Durable#durable?
    def durable?
      false
    end

    ##
    # @private
    # @see RDF::Enumerable#each
    def each
      @statements.each do |st| 
        if st.graph_name.equal?(DEFAULT_GRAPH)
          st = st.dup
          st.graph_name = nil
        end

        yield st
      end
      self
    end

    ##
    # Returns a developer-friendly representation of this object.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, uri.to_s)
    end

    ##
    # Outputs a developer-friendly representation of this object to
    # `stderr`.
    #
    # @return [void]
    def inspect!
      each_statement { |statement| statement.inspect! }
      nil
    end

    ##
    # @return [Symbol] a representation of the isolation level for reads of this
    #   Dataset. One of `:read_uncommitted`, `:read_committed`, `:repeatable_read`,
    #  `:snapshot`, or `:serializable`.
    def isolation_level
      :read_committed
    end

    ##
    # @private
    # @see RDF::Enumerable#supports?
    def supports?(feature)
      return true if feature == :graph_name
      super
    end

    protected
    
    ##
    # Implements basic query pattern matching over the Dataset, with handling 
    # for a default graph.
    def query_pattern(pattern, **options, &block)
      return super unless pattern.graph_name == DEFAULT_GRAPH

      if block_given?
        pattern = pattern.dup
        pattern.graph_name = nil

        each_statement do |statement|
          yield statement if (statement.graph_name == DEFAULT_GRAPH ||
                              statement.graph_name.nil?) && pattern === statement
        end
      else
        enum_for(:query_pattern, pattern, options)
      end
    end
  end
end
