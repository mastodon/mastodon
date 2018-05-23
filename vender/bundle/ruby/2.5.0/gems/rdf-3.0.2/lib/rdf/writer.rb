# -*- encoding: utf-8 -*-
module RDF
  ##
  # The base class for RDF serializers.
  #
  # @example Loading an RDF writer implementation
  #   require 'rdf/ntriples'
  #
  # @example Iterating over known RDF writer classes
  #   RDF::Writer.each { |klass| puts klass.name }
  #
  # @example Obtaining an RDF writer class
  #   RDF::Writer.for(:ntriples)     #=> RDF::NTriples::Writer
  #   RDF::Writer.for("spec/data/output.nt")
  #   RDF::Writer.for(file_name:      "spec/data/output.nt")
  #   RDF::Writer.for(file_extension: "nt")
  #   RDF::Writer.for(content_type:   "application/n-triples")
  #
  # @example Instantiating an RDF writer class
  #   RDF::Writer.for(:ntriples).new($stdout) { |writer| ... }
  #
  # @example Serializing RDF statements into a file
  #   RDF::Writer.open("spec/data/output.nt") do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @example Serializing RDF statements into a string
  #   RDF::Writer.for(:ntriples).buffer do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @example Detecting invalid output
  #   logger = Logger.new([])
  #   RDF::Writer.for(:ntriples).buffer(logger: logger) do |writer|
  #     statement = RDF::Statement.new(
  #       RDF::URI("http://rubygems.org/gems/rdf"),
  #       RDF::URI("http://purl.org/dc/terms/creator"),
  #       nil)
  #     writer << statement
  #   end # => RDF::WriterError
  #   logger.empty? => false
  #
  # @abstract
  # @see RDF::Format
  # @see RDF::Reader
  class Writer
    extend  ::Enumerable
    extend  RDF::Util::Aliasing::LateBound
    include RDF::Util::Logger
    include RDF::Writable

    ##
    # Enumerates known RDF writer classes.
    #
    # @yield  [klass]
    # @yieldparam  [Class] klass
    # @yieldreturn [void] ignored
    # @return [Enumerator]
    def self.each(&block)
      RDF::Format.map(&:writer).reject(&:nil?).each(&block)
    end

    ##
    # Finds an RDF writer class based on the given criteria.
    #
    # @overload for(format)
    #   Finds an RDF writer class based on a symbolic name.
    #
    #   @param  [Symbol] format
    #   @return [Class]
    #
    # @overload for(filename)
    #   Finds an RDF writer class based on a file name.
    #
    #   @param  [String] filename
    #   @return [Class]
    #
    # @overload for(**options)
    #   Finds an RDF writer class based on various options.
    #
    #   @param  [Hash{Symbol => Object}] options
    #   @option options [String, #to_s]   :file_name      (nil)
    #   @option options [Symbol, #to_sym] :file_extension (nil)
    #   @option options [String, #to_s]   :content_type   (nil)
    #   @return [Class]
    #
    # @return [Class]
    def self.for(options = {})
      options = options.merge(has_writer: true) if options.is_a?(Hash)
      if format = self.format || Format.for(options)
        format.writer
      end
    end

    ##
    # Retrieves the RDF serialization format class for this writer class.
    #
    # @return [Class]
    def self.format(klass = nil)
      if klass.nil?
        Format.each do |format|
          if format.writer == self
            return format
          end
        end
        nil # not found
      end
    end

    ##
    # Options suitable for automatic Writer provisioning.
    # @return [Array<RDF::CLI::Option>]
    def self.options
      [
        RDF::CLI::Option.new(
          symbol: :canonicalize,
          datatype: TrueClass,
          control: :checkbox,
          on: ["--canonicalize"],
          description: "Canonicalize input/output.") {true},
        RDF::CLI::Option.new(
          symbol: :encoding,
          datatype: Encoding,
          control: :text,
          on: ["--encoding ENCODING"],
          description: "The encoding of the input stream.") {|arg| Encoding.find arg},
        RDF::CLI::Option.new(
          symbol: :prefixes,
          datatype: Hash,
          multiple: true,
          control: :none,
          on: ["--prefixes PREFIX,PREFIX"],
          description: "A comma-separated list of prefix:uri pairs.") do |arg|
            arg.split(',').inject({}) do |memo, pfxuri|
              pfx,uri = pfxuri.split(':', 2)
              memo.merge(pfx.to_sym => RDF::URI(uri))
            end
        end,
        RDF::CLI::Option.new(
          symbol: :unique_bnodes,
          datatype: TrueClass,
          control: :checkbox,
          on: ["--unique-bnodes"],
          description: "Use unique Node identifiers.") {true},
      ]
    end

    class << self
      alias_method :format_class, :format
    end

    ##
    # @param  [RDF::Enumerable, #each] data
    #   the graph or repository to dump
    # @param  [IO, File, String] io
    #   the output stream or file to write to
    # @param [Encoding, String, Symbol] encoding
    #   the encoding to use on the output stream.
    #   Defaults to the format associated with `content_encoding`.
    # @param  [Hash{Symbol => Object}] options
    #   passed to {RDF::Writer#initialize} or {RDF::Writer.buffer}
    # @return [void]
    def self.dump(data, io = nil, encoding: nil, **options)
      if io.is_a?(String)
        io = File.open(io, 'w')
      elsif io.respond_to?(:external_encoding) && io.external_encoding
        encoding ||= io.external_encoding
      end
      io.set_encoding(encoding) if io.respond_to?(:set_encoding) && encoding
      method = data.respond_to?(:each_statement) ? :each_statement : :each
      if io
        new(io, encoding: encoding, **options) do |writer|
          data.send(method) do |statement|
            writer << statement
          end
          writer.flush
        end
      else
        buffer(encoding: encoding, **options) do |writer|
          data.send(method) do |statement|
            writer << statement
          end
        end
      end
    end

    ##
    # Buffers output into a string buffer.
    #
    # @param [Encoding, String, Symbol] encoding
    #   the encoding to use on the output stream.
    #   Defaults to the format associated with `content_encoding`.
    # @param  [Hash{Symbol => Object}] options
    #   passed to {RDF::Writer#initialize}
    # @yield  [writer]
    # @yieldparam  [RDF::Writer] writer
    # @yieldreturn [void]
    # @return [String]
    # @raise [ArgumentError] if no block is provided
    def self.buffer(*args, encoding: nil, **options, &block)
      encoding ||= Encoding::UTF_8 if RUBY_PLATFORM == "java"
      raise ArgumentError, "block expected" unless block_given?

      StringIO.open do |buffer|
        buffer.set_encoding(encoding) if encoding
        self.new(buffer, *args, encoding: encoding, **options) { |writer| block.call(writer) }
        buffer.string
      end
    end

    ##
    # Writes output to the given `filename`.
    #
    # @param  [String, #to_s] filename
    # @param [Encoding, String, Symbol] encoding
    #   the encoding to use on the output stream.
    #   Defaults to the format associated with `content_encoding`.
    # @param [Symbol] format (nil)
    # @param  [Hash{Symbol => Object}] options
    #   any additional options (see {RDF::Writer#initialize} and {RDF::Format.for})
    # @return [RDF::Writer]
    def self.open(filename, encoding: nil, format: nil, **options, &block)
      File.open(filename, 'wb') do |file|
        file.set_encoding(encoding) if encoding
        format_options = options.dup
        format_options[:file_name] ||= filename
        self.for(format || format_options).new(file, encoding: encoding, **options, &block)
      end
    end

    ##
    # Returns a symbol appropriate to use with RDF::Writer.for()
    # @return [Symbol]
    def self.to_sym
      self.format.to_sym
    end

    ##
    # Returns a symbol appropriate to use with RDF::Writer.for()
    # @return [Symbol]
    def to_sym
      self.class.to_sym
    end
    
    ##
    # Initializes the writer.
    #
    # @param  [IO, File] output
    #   the output stream
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Encoding, String, Symbol] :encoding
    #   the encoding to use on the output stream.
    #   Defaults to the format associated with `content_encoding`.
    # @option options [Boolean]  :canonicalize (false)
    #   whether to canonicalize terms when serializing
    # @option options [Boolean]  :validate (false)
    #   whether to validate terms when serializing
    # @option options [Hash]     :prefixes     (Hash.new)
    #   the prefix mappings to use (not supported by all writers)
    # @option options [#to_s]    :base_uri     (nil)
    #   the base URI to use when constructing relative URIs (not supported
    #   by all writers)
    # @option options [Boolean]  :unique_bnodes   (false)
    #   Use unique {Node} identifiers, defaults to using the identifier which the node was originall initialized with (if any). Implementations should ensure that Nodes are serialized using a unique representation independent of any identifier used when creating the node. See {NTriples::Writer#format_node}
    # @yield  [writer] `self`
    # @yieldparam  [RDF::Writer] writer
    # @yieldreturn [void]
    def initialize(output = $stdout, **options, &block)
      @output, @options = output, options.dup
      @nodes, @node_id, @node_id_map  = {}, 0, {}

      if block_given?
        write_prologue
        case block.arity
          when 1 then block.call(self)
          else instance_eval(&block)
        end
        write_epilogue
      end
    end

    ##
    # Any additional options for this writer.
    #
    # @return [Hash]
    # @since  0.2.2
    attr_reader :options

    ##
    # Returns the base URI used for this writer.
    #
    # @example
    #   writer.prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [RDF::URI]
    # @since  0.3.4
    def base_uri
      RDF::URI(@options[:base_uri]) if @options[:base_uri]
    end

    ##
    # Returns the URI prefixes currently defined for this writer.
    #
    # @example
    #   writer.prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.2.2
    def prefixes
      @options[:prefixes] ||= {}
    end

    ##
    # Defines the given URI prefixes for this writer.
    #
    # @example
    #   writer.prefixes = {
    #     dc: RDF::URI('http://purl.org/dc/terms/'),
    #   }
    #
    # @param  [Hash{Symbol => RDF::URI}] prefixes
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes=(prefixes)
      @options[:prefixes] = prefixes
    end

    ##
    # Defines the given named URI prefix for this writer.
    #
    # @example Defining a URI prefix
    #   writer.prefix :dc, RDF::URI('http://purl.org/dc/terms/')
    #
    # @example Returning a URI prefix
    #   writer.prefix(:dc)    #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @overload prefix(name, uri)
    #   @param  [Symbol, #to_s]   name
    #   @param  [RDF::URI, #to_s] uri
    #
    # @overload prefix(name)
    #   @param  [Symbol, #to_s]   name
    #
    # @return [RDF::URI]
    def prefix(name, uri = nil)
      name = name.to_s.empty? ? nil : (name.respond_to?(:to_sym) ? name.to_sym : name.to_s.to_sym)
      uri.nil? ? prefixes[name] : prefixes[name] = uri
    end
    alias_method :prefix!, :prefix

    ##
    # Returns the encoding of the output stream.
    #
    # @return [Encoding]
    def encoding
      case @options[:encoding]
      when String, Symbol
        Encoding.find(@options[:encoding].to_s)
      when Encoding
        @options[:encoding]
      else
        @options[:encoding] ||= Encoding.find(self.class.format.content_encoding.to_s)
      end
    end

    ##
    # Returns `true` if statements and terms should be validated.
    #
    # @return [Boolean] `true` or `false`
    # @since  1.0.8
    def validate?
      @options[:validate]
    end

    ##
    # Returns `true` if terms should be canonicalized.
    #
    # @return [Boolean] `true` or `false`
    # @since  1.0.8
    def canonicalize?
      @options[:canonicalize]
    end

    ##
    # Flushes the underlying output buffer.
    #
    # @return [self]
    def flush
      @output.flush if @output.respond_to?(:flush)
      self
    end
    alias_method :flush!, :flush

    ##
    # @return [self]
    # @abstract
    def write_prologue
      @logged_errors_at_prolog = log_statistics[:error].to_i
      self
    end

    ##
    # @return [self]
    # @raise [RDF::WriterError] if errors logged during processing.
    # @abstract
    def write_epilogue
      if log_statistics[:error].to_i > @logged_errors_at_prolog
        raise RDF::WriterError, "Errors found during processing"
      end
      self
    end

    ##
    # @param  [String] text
    # @return [self]
    # @abstract
    def write_comment(text)
      self
    end

    ##
    # Add a statement to the writer. This will check to ensure that the statement is complete (no nil terms) and is valid, if the `:validation` option is set.
    #
    # Additionally, it will de-duplicate BNode terms sharing a common identifier.
    #
    # @param  [RDF::Statement] statement
    # @return [self]
    # @note logs error if attempting to write an invalid {RDF::Statement} or if canonicalizing a statement which cannot be canonicalized.
    def write_statement(statement)
      statement = statement.canonicalize! if canonicalize?

      # Make sure BNodes in statement use unique identifiers
      if statement.node?
        statement.to_quad.map do |term|
          if term.is_a?(RDF::Node)
            term = term.original while term.original
            @nodes[term] ||= begin
              # Account for duplicated nodes
              @node_id_map[term.to_s] ||= term
              if !@node_id_map[term.to_s].equal?(term)
                # Rename node
                term.make_unique!
                @node_id_map[term.to_s] = term
              end
            end
          else
            term
          end
        end
        statement = RDF::Statement.from(statement.to_quad)
      end

      if statement.incomplete?
        log_error "Statement #{statement.inspect} is incomplete"
      elsif validate? && statement.invalid?
        log_error "Statement #{statement.inspect} is invalid"
      elsif respond_to?(:write_quad)
        write_quad(*statement.to_quad)
      else
        write_triple(*statement.to_triple)
      end
      self
    rescue ArgumentError => e
      log_error e.message
    end
    alias_method :insert_statement, :write_statement # support the RDF::Writable interface

    ##
    # @param  [Array<Array(RDF::Resource, RDF::URI, RDF::Term)>] triples
    # @return [self]
    # @note logs error if attempting to write an invalid {RDF::Statement} or if canonicalizing a statement which cannot be canonicalized.
    def write_triples(*triples)
      triples.each { |triple| write_triple(*triple) }
      self
    end

    ##
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI]      predicate
    # @param  [RDF::Term]     object
    # @return [self]
    # @raise  [NotImplementedError] unless implemented in subclass
    # @note logs error if attempting to write an invalid {RDF::Statement} or if canonicalizing a statement which cannot be canonicalized.
    # @abstract
    def write_triple(subject, predicate, object)
      raise NotImplementedError.new("#{self.class}#write_triple") # override in subclasses
    end

    ##
    # @param  [RDF::Term] term
    # @return [String]
    # @since  0.3.0
    def format_term(term, **options)
      case term
        when String       then format_literal(RDF::Literal(term, options), options)
        when RDF::List    then format_list(term, options)
        when RDF::Literal then format_literal(term, options)
        when RDF::URI     then format_uri(term, options)
        when RDF::Node    then format_node(term, options)
        else nil
      end
    end

    ##
    # @param  [RDF::Node] value
    # @param  [Hash{Symbol => Object}] options = ({})
    # @option options [Boolean] :unique_bnodes (false)
    #   Serialize node using unique identifier, rather than any used to create the node.
    # @return [String]
    # @raise  [NotImplementedError] unless implemented in subclass
    # @abstract
    def format_node(value, **options)
      raise NotImplementedError.new("#{self.class}#format_node") # override in subclasses
    end

    ##
    # @param  [RDF::URI] value
    # @param  [Hash{Symbol => Object}] options = ({})
    # @return [String]
    # @raise  [NotImplementedError] unless implemented in subclass
    # @abstract
    def format_uri(value, **options)
      raise NotImplementedError.new("#{self.class}#format_uri") # override in subclasses
    end

    ##
    # @param  [RDF::Literal, String, #to_s] value
    # @param  [Hash{Symbol => Object}] options = ({})
    # @return [String]
    # @raise  [NotImplementedError] unless implemented in subclass
    # @abstract
    def format_literal(value, **options)
      raise NotImplementedError.new("#{self.class}#format_literal") # override in subclasses
    end

    ##
    # @param  [RDF::List] value
    # @param  [Hash{Symbol => Object}] options = ({})
    # @return [String]
    # @abstract
    # @since  0.2.3
    def format_list(value, **options)
      format_term(value.subject, options)
    end

  protected

    ##
    # @return [void]
    def puts(*args)
      @output.puts(*args.map {|s| s.encode(encoding)})
    end

    ##
    # @param  [RDF::Resource] term
    # @return [String]
    def uri_for(term)
      case
        when term.is_a?(RDF::Node)
          @nodes[term] ||= term.to_base
        when term.respond_to?(:to_uri)
          term.to_uri.to_s
        else
          term.to_s
      end
    end

    ##
    # @return [String]
    def node_id
      "_:n#{@node_id += 1}"
    end

    ##
    # @param  [String] string
    # @return [String]
    def escaped(string)
      string.gsub('\\', '\\\\\\\\').
             gsub("\b", '\\b').
             gsub("\f", '\\f').
             gsub("\t", '\\t').
             gsub("\n", '\\n').
             gsub("\r", '\\r').
             gsub('"', '\\"')
    end

    ##
    # @param  [String] string
    # @return [String]
    def quoted(string)
      "\"#{string}\""
    end

  private

    @@subclasses = [] # @private

    ##
    # @private
    # @return [void]
    def self.inherited(child)
      @@subclasses << child
      super
    end
  end # Writer

  ##
  # The base class for RDF serialization errors.
  class WriterError < IOError
  end # WriterError
end # RDF
