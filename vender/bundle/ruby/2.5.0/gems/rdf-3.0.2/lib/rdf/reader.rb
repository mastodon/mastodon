module RDF
  ##
  # The base class for RDF parsers.
  #
  # @example Loading an RDF reader implementation
  #   require 'rdf/ntriples'
  #
  # @example Iterating over known RDF reader classes
  #   RDF::Reader.each { |klass| puts klass.name }
  #
  # @example Obtaining an RDF reader class
  #   RDF::Reader.for(:ntriples)     #=> RDF::NTriples::Reader
  #   RDF::Reader.for("etc/doap.nt")
  #   RDF::Reader.for(file_name:      "etc/doap.nt")
  #   RDF::Reader.for(file_extension: "nt")
  #   RDF::Reader.for(content_type:   "application/n-triples")
  #
  # @example Instantiating an RDF reader class
  #   RDF::Reader.for(:ntriples).new($stdin) { |reader| ... }
  #
  # @example Parsing RDF statements from a file
  #   RDF::Reader.open("etc/doap.nt") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @example Parsing RDF statements from a string
  #   data = StringIO.new(File.read("etc/doap.nt"))
  #   RDF::Reader.for(:ntriples).new(data) do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @abstract
  # @see RDF::Format
  # @see RDF::Writer
  class Reader
    extend  ::Enumerable
    extend  RDF::Util::Aliasing::LateBound
    include RDF::Util::Logger
    include RDF::Readable
    include RDF::Enumerable # @since 0.3.0

    ##
    # Enumerates known RDF reader classes.
    #
    # @yield  [klass]
    # @yieldparam [Class] klass
    # @return [Enumerator]
    def self.each(&block)
      RDF::Format.map(&:reader).reject(&:nil?).each(&block)
    end

    ##
    # Finds an RDF reader class based on the given criteria.
    #
    # If the reader class has a defined format, use that.
    #
    # @overload for(format)
    #   Finds an RDF reader class based on a symbolic name.
    #
    #   @param  [Symbol] format
    #   @return [Class]
    #
    # @overload for(filename)
    #   Finds an RDF reader class based on a file name.
    #
    #   @param  [String] filename
    #   @return [Class]
    #
    # @overload for(options = {})
    #   Finds an RDF reader class based on various options.
    #
    #   @param  [Hash{Symbol => Object}] options
    #   @option options [String, #to_s]   :file_name      (nil)
    #   @option options [Symbol, #to_sym] :file_extension (nil)
    #   @option options [String, #to_s]   :content_type   (nil)
    #   @return [Class]
    #   @option options [String]          :sample (nil)
    #     A sample of input used for performing format detection.
    #     If we find no formats, or we find more than one, and we have a sample, we can
    #     perform format detection to find a specific format to use, in which case
    #     we pick the first one we find
    #   @return [Class]
    #   @yieldreturn [String] another way to provide a sample, allows lazy for retrieving the sample.
    #
    # @return [Class]
    def self.for(options = {}, &block)
      options = options.merge(has_reader: true) if options.is_a?(Hash)
      if format = self.format || Format.for(options, &block)
        format.reader
      end
    end

    ##
    # Retrieves the RDF serialization format class for this reader class.
    #
    # @return [Class]
    def self.format(klass = nil)
      if klass.nil?
        Format.each do |format|
          if format.reader == self
            return format
          end
        end
        nil # not found
      end
    end

    ##
    # Options suitable for automatic Reader provisioning.
    # @return [Array<RDF::CLI::Option>]
    def self.options
      [
        RDF::CLI::Option.new(
          symbol: :canonicalize,
          datatype: TrueClass,
          on: ["--canonicalize"],
          control: :checkbox,
          default: false,
          description: "Canonicalize input/output.") {true},
        RDF::CLI::Option.new(
          symbol: :encoding,
          datatype: Encoding,
          control: :text,
          on: ["--encoding ENCODING"],
          description: "The encoding of the input stream.") {|arg| Encoding.find arg},
        RDF::CLI::Option.new(
          symbol: :intern,
          datatype: TrueClass,
          control: :none,
          on: ["--intern"],
          description: "Intern all parsed URIs."),
        RDF::CLI::Option.new(
          symbol: :prefixes,
          datatype: Hash,
          control: :none,
          multiple: true,
          on: ["--prefixes PREFIX:URI,PREFIX:URI"],
          description: "A comma-separated list of prefix:uri pairs.") do |arg|
            arg.split(',').inject({}) do |memo, pfxuri|
              pfx,uri = pfxuri.split(':', 2)
              memo.merge(pfx.to_sym => RDF::URI(uri))
            end
        end,
        RDF::CLI::Option.new(
          symbol: :base_uri,
          control: :url,
          datatype: RDF::URI,
          on: ["--uri URI"],
          description: "Base URI of input file, defaults to the filename.") {|arg| RDF::URI(arg)},
        RDF::CLI::Option.new(
          symbol: :validate,
          datatype: TrueClass,
          control: :checkbox,
          on: ["--validate"],
          description: "Validate input file."),
        RDF::CLI::Option.new(
          symbol: :verifySSL,
          datatype: TrueClass,
          default: true,
          control: :checkbox,
          on: ["--[no-]verifySSL"],
          description: "Verify SSL results on HTTP GET")
      ]
    end

    # Returns a hash of options appropriate for use with this reader
    
    class << self
      alias_method :format_class, :format
    end

    ##
    # Parses input from the given file name or URL.
    #
    # @note A reader returned via this method may not be readable depending on the processing model of the specific reader, as the file is only open during the scope of `open`. The reader is intended to be accessed through a block.
    #
    # @example Parsing RDF statements from a file
    #   RDF::Reader.open("etc/doap.nt") do |reader|
    #     reader.each_statement do |statement|
    #       puts statement.inspect
    #     end
    #   end
    #
    # @param  [String, #to_s] filename
    # @param [Symbol] format
    # @param  [Hash{Symbol => Object}] options
    #   any additional options (see {RDF::Util::File.open_file}, {RDF::Reader#initialize} and {RDF::Format.for})
    # @yield  [reader]
    # @yieldparam  [RDF::Reader] reader
    # @yieldreturn [void] ignored
    # @raise  [RDF::FormatError] if no reader found for the specified format
    def self.open(filename, format: nil, **options, &block)
      # If we're the abstract reader, and we can figure out a concrete reader from format, use that.
      if self == RDF::Reader && format && reader = self.for(format)
        return reader.open(filename, format: format, **options, &block)
      end

      # If we are a concrete reader class or format is not nil, set accept header from our content_types.
      unless self == RDF::Reader
        headers = (options[:headers] ||= {})
        headers['Accept'] ||= (self.format.accept_type + %w(*/*;q=0.1)).join(", ")
      end

      Util::File.open_file(filename, options) do |file|
        format_options = options.dup
        format_options[:content_type] ||= file.content_type if
          file.respond_to?(:content_type) &&
          !file.content_type.to_s.include?('text/plain')
        format_options[:file_name] ||= filename
        reader = if self == RDF::Reader
          # We are the abstract reader class, find an appropriate reader
          self.for(format || format_options) do
            # Return a sample from the input file
            sample = file.read(1000)
            file.rewind
            sample
          end
        else
          # We are a concrete reader class
          self
        end

        options[:encoding] ||= file.encoding if file.respond_to?(:encoding)
        options[:filename] ||= filename

        if reader
          reader.new(file, options, &block)
        else
          raise FormatError, "unknown RDF format: #{format_options.inspect}#{"\nThis may be resolved with a require of the 'linkeddata' gem." unless Object.const_defined?(:LinkedData)}"
        end
      end
    end

    ##
    # Returns a symbol appropriate to use with RDF::Reader.for()
    # @return [Symbol]
    def self.to_sym
      self.format.to_sym
    end

    ##
    # Returns a symbol appropriate to use with RDF::Reader.for()
    # @return [Symbol]
    def to_sym
      self.class.to_sym
    end
    
    ##
    # Initializes the reader.
    #
    # @param  [IO, File, String] input
    #   the input stream to read
    # @param [Encoding] encoding     (Encoding::UTF_8)
    #   the encoding of the input stream
    # @param [Boolean]  validate     (false)
    #   whether to validate the parsed statements and values
    # @param [Boolean]  canonicalize (false)
    #   whether to canonicalize parsed literals
    # @param [Boolean]  intern       (true)
    #   whether to intern all parsed URIs
    # @param [Hash]     prefixes     (Hash.new)
    #   the prefix mappings to use (not supported by all readers)
    # @param [#to_s]    base_uri     (nil)
    #   the base URI to use when resolving relative URIs (not supported by
    #   all readers)
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @yield  [reader] `self`
    # @yieldparam  [RDF::Reader] reader
    # @yieldreturn [void] ignored
    def initialize(input = $stdin,
                   encoding:      Encoding::UTF_8,
                   validate:      false,
                   canonicalize:  false,
                   intern:        true,
                   prefixes:      Hash.new,
                   base_uri:      nil,
                   **options,
                   &block)

      base_uri     ||= input.base_uri if input.respond_to?(:base_uri)
      @options = options.merge({
        encoding:       encoding,
        validate:       validate,
        canonicalize:   canonicalize,
        intern:         intern,
        prefixes:       prefixes,
        base_uri:       base_uri
      })

      @input = case input
        when String then StringIO.new(input)
        else input
      end

      if block_given?
        case block.arity
          when 0 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    ##
    # Any additional options for this reader.
    #
    # @return [Hash]
    # @since  0.3.0
    attr_reader :options

    ##
    # Returns the base URI determined by this reader.
    #
    # @example
    #   reader.prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [RDF::URI]
    # @since  0.3.0
    def base_uri
      RDF::URI(@options[:base_uri]) if @options[:base_uri]
    end

    ##
    # Returns the URI prefixes currently defined for this reader.
    #
    # @example
    #   reader.prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes
      @options[:prefixes] ||= {}
    end

    ##
    # Defines the given URI prefixes for this reader.
    #
    # @example
    #   reader.prefixes = {
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
    # Defines the given named URI prefix for this reader.
    #
    # @example Defining a URI prefix
    #   reader.prefix :dc, RDF::URI('http://purl.org/dc/terms/')
    #
    # @example Returning a URI prefix
    #   reader.prefix(:dc)    #=> RDF::URI('http://purl.org/dc/terms/')
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
    # Iterates the given block for each RDF statement.
    #
    # If no block was given, returns an enumerator.
    #
    # Statements are yielded in the order that they are read from the input
    # stream.
    #
    # @overload each_statement
    #   @yield  [statement]
    #     each statement
    #   @yieldparam  [RDF::Statement] statement
    #   @yieldreturn [void] ignored
    #   @return [void]
    #
    # @overload each_statement
    #   @return [Enumerator]
    #
    # @return [void]
    # @raise  [RDF::ReaderError] on invalid data
    # @see    RDF::Enumerable#each_statement
    def each_statement(&block)
      if block_given?
        begin
          loop { block.call(read_statement) }
        rescue EOFError
          rewind rescue nil
        end
      end
      enum_for(:each_statement)
    end
    alias_method :each, :each_statement

    ##
    # Iterates the given block for each RDF triple.
    #
    # If no block was given, returns an enumerator.
    #
    # Triples are yielded in the order that they are read from the input
    # stream.
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
    #   @return [Enumerator]
    #
    # @return [void]
    # @see    RDF::Enumerable#each_triple
    def each_triple(&block)
      if block_given?
        begin
          loop { block.call(*read_triple) }
        rescue EOFError
          rewind rescue nil
        end
      end
      enum_for(:each_triple)
    end

    ##
    # Rewinds the input stream to the beginning of input.
    #
    # @return [void]
    # @since  0.2.3
    # @see    http://ruby-doc.org/core-2.2.2/IO.html#method-i-rewind
    def rewind
      @input.rewind
    end
    alias_method :rewind!, :rewind

    ##
    # Closes the input stream, after which an `IOError` will be raised for
    # further read attempts.
    #
    # If the input stream is already closed, does nothing.
    #
    # @return [void]
    # @since  0.2.2
    # @see    http://ruby-doc.org/core-2.2.2/IO.html#method-i-close
    def close
      @input.close unless @input.closed?
    end
    alias_method :close!, :close

    ##
    # Current line number being processed. For formats that can associate generated {Statement} with a particular line number from input, this value reflects that line number.
    # @return [Integer]
    def lineno
      @input.lineno
    end

    ##
    # @return [Boolean]
    #
    # @note this parses the full input and is valid only in the reader block.
    #   Use `Reader.new(input, validate: true)` if you intend to capture the 
    #   result.
    #
    # @example Parsing RDF statements from a file
    #   RDF::NTriples::Reader.new("!!invalid input??") do |reader|
    #     reader.valid? # => false
    #   end
    #
    # @see RDF::Value#validate! for Literal & URI validation relevant to 
    #   error handling.
    # @see Enumerable#valid?
    def valid?
      super && !log_statistics[:error]
    rescue ArgumentError, RDF::ReaderError => e
      log_error(e.message)
      false
    end

  protected

    ##
    # Reads a statement from the input stream.
    #
    # @return [RDF::Statement] a statement
    # @raise  [NotImplementedError] unless implemented in subclass
    # @abstract
    def read_statement
      Statement.new(*read_triple)
    end

    ##
    # Reads a triple from the input stream.
    #
    # @return [Array(RDF::Term)] a triple
    # @raise  [NotImplementedError] unless implemented in subclass
    # @abstract
    def read_triple
      raise NotImplementedError, "#{self.class}#read_triple" # override in subclasses
    end

    ##
    # Raises an "expected subject" parsing error on the current line.
    #
    # @return [void]
    # @raise  [RDF::ReaderError]
    def fail_subject
      log_error("Expected subject (found: #{current_line.inspect})", lineno: lineno, exception: RDF::ReaderError)
    end

    ##
    # Raises an "expected predicate" parsing error on the current line.
    #
    # @return [void]
    # @raise  [RDF::ReaderError]
    def fail_predicate
      log_error("Expected predicate (found: #{current_line.inspect})", lineno: lineno, exception: RDF::ReaderError)
    end

    ##
    # Raises an "expected object" parsing error on the current line.
    #
    # @return [void]
    # @raise  [RDF::ReaderError]
    def fail_object
      log_error("Expected object (found: #{current_line.inspect})", lineno: lineno, exception: RDF::ReaderError)
    end

  public
    ##
    # Returns the encoding of the input stream.
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
    # Returns `true` if parsed statements and values should be validated.
    #
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def validate?
      @options[:validate]
    end

    ##
    # Returns `true` if parsed values should be canonicalized.
    #
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def canonicalize?
      @options[:canonicalize]
    end

    ##
    # Returns `true` if parsed URIs should be interned.
    #
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def intern?
      @options[:intern]
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

    ##
    # @private
    # @return [String] The most recently read line of the input
    def current_line
      @line
    end

    ##
    # @return [String]
    def readline
      @line = @line_rest || @input.readline
      @line, @line_rest = @line.split("\r", 2)
      @line = @line.to_s.chomp
      begin
        @line.encode!(encoding)
      rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError, Encoding::ConverterNotFoundError
        # It is likely the persisted line was not encoded on initial write
        # (i.e. persisted via RDF <= 1.0.9 and read via RDF >= 1.0.10)
        #
        # Encoding::UndefinedConversionError is raised by MRI.
        # Encoding::InvalidByteSequenceError is raised by jruby >= 1.7.5
        # Encoding::ConverterNotFoundError is raised by jruby < 1.7.5
        @line.force_encoding(encoding)
      end
      @line
    end

    ##
    # @return [void]
    def strip!
      @line.strip!
    end

    ##
    # @return [Boolean]
    def blank?
      @line.nil? || @line.empty?
    end

    ##
    # @param  [Regexp] pattern
    # @return [Object]
    def match(pattern)
      if @line =~ pattern
        result, @line = $1, $'.lstrip
        result || true
      end
    end
  end # Reader

  ##
  # The base class for RDF parsing errors.
  class ReaderError < IOError
    ##
    # The invalid token which triggered the error.
    #
    # @return [String]
    attr_reader :token

    ##
    # The line number where the error occurred.
    #
    # @return [Integer]
    attr_reader :lineno

    ##
    # Initializes a new lexer error instance.
    #
    # @param  [String, #to_s]  message
    # @param  [String]         token  (nil)
    # @param  [Integer]        lineno (nil)
    def initialize(message, token: nil, lineno: nil)
      @token      = token
      @lineno     = lineno || (token.lineno if token.respond_to?(:lineno))
      super(message.to_s)
    end
  end # ReaderError
end # RDF
