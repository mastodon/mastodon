require 'stringio'
require 'bigdecimal'
require 'date'
require 'time'

require 'rdf/version'

module RDF
  # RDF mixins
  autoload :Countable,         'rdf/mixin/countable'
  autoload :Durable,           'rdf/mixin/durable'
  autoload :Enumerable,        'rdf/mixin/enumerable'
  autoload :Indexable,         'rdf/mixin/indexable'
  autoload :Mutable,           'rdf/mixin/mutable'
  autoload :Queryable,         'rdf/mixin/queryable'
  autoload :Readable,          'rdf/mixin/readable'
  autoload :TypeCheck,         'rdf/mixin/type_check'
  autoload :Transactable,      'rdf/mixin/transactable'
  autoload :Writable,          'rdf/mixin/writable'

  # RDF objects
  autoload :Graph,             'rdf/model/graph'
  autoload :IRI,               'rdf/model/uri'
  autoload :Literal,           'rdf/model/literal'
  autoload :Node,              'rdf/model/node'
  autoload :Resource,          'rdf/model/resource'
  autoload :Statement,         'rdf/model/statement'
  autoload :URI,               'rdf/model/uri'
  autoload :Value,             'rdf/model/value'
  autoload :Term,              'rdf/model/term'

  # RDF collections
  autoload :List,              'rdf/model/list'

  # RDF serialization
  autoload :Format,            'rdf/format'
  autoload :Reader,            'rdf/reader'
  autoload :ReaderError,       'rdf/reader'
  autoload :Writer,            'rdf/writer'
  autoload :WriterError,       'rdf/writer'

  # RDF serialization formats
  autoload :NTriples,          'rdf/ntriples'
  autoload :NQuads,            'rdf/nquads'

  # RDF storage
  autoload :Changeset,         'rdf/changeset'
  autoload :Dataset,           'rdf/model/dataset'
  autoload :Repository,        'rdf/repository'
  autoload :Transaction,       'rdf/transaction'

  # RDF querying
  autoload :Query,             'rdf/query'

  # RDF vocabularies
  autoload :Vocabulary,        'rdf/vocabulary'
  autoload :StrictVocabulary,  'rdf/vocabulary'
  VOCABS = Dir.glob(File.expand_path("../rdf/vocab/*.rb", __FILE__)).map { |f| File.basename(f)[0...-(File.extname(f).size)].to_sym } rescue []

  # Use const_missing instead of autoload to load most vocabularies so we can provide deprecation messages
  def self.const_missing(constant)
    if VOCABS.include?(constant.to_s.downcase.to_sym)
      require "rdf/vocab/#{constant.to_s.downcase}"
      const_get(constant)
    else
      super
    end
  end

  # Utilities
  autoload :Util,        'rdf/util'

  ##
  # Alias for `RDF::Resource.new`.
  #
  # @param (see RDF::Resource#initialize)
  # @return [RDF::Resource]
  def self.Resource(*args, &block)
    Resource.new(*args, &block)
  end

  ##
  # Alias for `RDF::Node.new`.
  #
  # @param (see RDF::Node#initialize)
  # @return [RDF::Node]
  def self.Node(*args, &block)
    Node.new(*args, &block)
  end

  ##
  # Cast to a URI. If already a URI, return the passed argument.
  #
  # @param (see RDF::URI#initialize)
  # @return [RDF::URI]
  def self.URI(uri, *args, &block)
    uri.respond_to?(:to_uri) ? uri.to_uri : URI.new(uri, *args, &block)
  end

  ##
  # Alias for `RDF::Literal.new`.
  #
  # @param (see RDF::Literal#initialize)
  # @return [RDF::Literal]
  def self.Literal(literal, *args, &block)
    case literal
      when RDF::Literal then literal
      else Literal.new(literal, *args, &block)
    end
  end

  ##
  # Alias for `RDF::Graph.new`.
  #
  # @param (see RDF::Graph#initialize)
  # @return [RDF::Graph]
  def self.Graph(**options, &block)
    Graph.new(options, &block)
  end

  ##
  # @overload List()
  #   @return [RDF::URI] returns the IRI for `rdf:List`
  #
  # @overload List(*args)
  #   @param (see RDF::List#[])
  #   @return [RDF::List]
  #
  # @overload List(array)
  #   @param [Array] array
  #   @return [RDF::List]
  #
  # @overload List(list)
  #   @param [RDF::List] list
  #   @return [RDF::List] returns itself
  def self.List(*args)
    case
    when args.empty?
      RDF[:List]
    when args.length == 1 && args.first.is_a?(RDF::List)
      args.first
    when args.length == 1 && args.first.is_a?(Array)
      List[*args.first]
    else
      List[*args]
    end
  end

  ##
  # @overload Statement()
  #   @return [RDF::URI] returns the IRI for `rdf:Statement`
  #
  # @overload Statement(**options)
  #   @param  [Hash{Symbol => Object}] options
  #   @option options [RDF::Resource]  :subject   (nil)
  #   @option options [RDF::URI]       :predicate (nil)
  #   @option options [RDF::Term]      :object    (nil)
  #   @option options [RDF::Resource]  :graph_name   (nil)
  #     Note, a graph_name MUST be an IRI or BNode.
  #   @return [RDF::Statement]
  #
  # @overload Statement(subject, predicate, object, **options)
  #   @param  [RDF::Resource]          subject
  #   @param  [RDF::URI]               predicate
  #   @param  [RDF::Term]              object
  #   @param  [Hash{Symbol => Object}] options
  #   @option options [RDF::Resource]  :graph_name   (nil)
  #   @return [RDF::Statement]
  #
  def self.Statement(*args)
    if args.empty?
      RDF[:Statement]
    else
      Statement.new(*args)
    end
  end

  ##
  # Alias for `RDF::Vocabulary.create`.
  #
  # @param (see RDF::Vocabulary#initialize)
  # @return [Class]
  def self.Vocabulary(uri)
    Vocabulary.create(uri)
  end

  ##
  # Alias for `RDF::StrictVocabulary.create`.
  #
  # @param (see RDF::Vocabulary#initialize)
  # @return [Class]
  def self.StrictVocabulary(prefix)
    StrictVocabulary.create(prefix)
  end

  ##
  # @return [#to_s] property
  # @return [URI]
  def self.[](property)
    property.to_s =~ %r{_\d+} ? RDF::URI("#{to_uri}#{property}") : RDF::RDFV[property]
  end

  ##
  # Return an enumerator over {RDF::Statement} defined for this vocabulary.
  # @return [RDF::Enumerable::Enumerator]
  # @see    Object#enum_for
  def self.enum_for(method = :each_statement, *args)
    # Ensure that enumerators are, themselves, queryable
    Enumerable::Enumerator.new do |yielder|
      RDF::RDFV.send(method, *args) {|*y| yielder << (y.length > 1 ? y : y.first)}
    end
  end
  class << self
    alias_method :to_enum, :enum_for
  end

  ##
  # respond to module or RDFV
  def self.respond_to?(method, include_all = false)
    super || RDF::RDFV.respond_to?(method, include_all)
  end

  RDF_N_REGEXP = %r{_\d+}.freeze

  ##
  # Delegate other methods to RDF::RDFV
  def self.method_missing(property, *args, &block)
    if args.empty?
      # Special-case rdf:_n for all integers
      RDF_N_REGEXP.match(property) ? RDF::URI("#{to_uri}#{property}") : RDF::RDFV.send(property)
    else
      super
    end
  end
end
