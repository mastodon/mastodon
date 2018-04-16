# -*- encoding: utf-8 -*-
module RDF
  ##
  # An RDF literal.
  #
  # Subclasses of {RDF::Literal} should define DATATYPE and GRAMMAR constants, which are used for identifying the appropriate class to use for a datatype URI and to perform lexical matching on the value.
  #
  # Literal comparison with other {RDF::Value} instances call {RDF::Value#type_error}, which, returns false. Implementations wishing to have {RDF::TypeError} raised should mix-in {RDF::TypeCheck}. This is required for strict SPARQL conformance.
  #
  # Specific typed literals may have behavior different from the default implementation. See the following defined sub-classes for specific documentation. Additional sub-classes may be defined, and will interoperate by defining `DATATYPE` and `GRAMMAR` constants, in addition other required overrides of RDF::Literal behavior.
  #
  # In RDF 1.1, all literals are typed, including plain literals and language tagged literals. Internally, plain literals are given the `xsd:string` datatype and language tagged literals are given the `rdf:langString` datatype. Creating a plain literal, without a datatype or language, will automatically provide the `xsd:string` datatype; similar for language tagged literals. Note that most serialization formats will remove this datatype. Code which depends on a literal having the `xsd:string` datatype being different from a plain literal (formally, without a datatype) may break. However note that the `#has\_datatype?` will continue to return `false` for plain or language-tagged literals.
  #
  # * {RDF::Literal::Boolean}
  # * {RDF::Literal::Date}
  # * {RDF::Literal::DateTime}
  # * {RDF::Literal::Decimal}
  # * {RDF::Literal::Double}
  # * {RDF::Literal::Integer}
  # * {RDF::Literal::Time}
  #
  # @example Creating a plain literal
  #   value = RDF::Literal.new("Hello, world!")
  #   value.plain?                                   #=> true`
  #
  # @example Creating a language-tagged literal (1)
  #   value = RDF::Literal.new("Hello!", language: :en)
  #   value.has_language?                            #=> true
  #   value.language                                 #=> :en
  #
  # @example Creating a language-tagged literal (2)
  #   RDF::Literal.new("Wazup?", language: :"en-US")
  #   RDF::Literal.new("Hej!",   language: :sv)
  #   RDF::Literal.new("¡Hola!", language: :es)
  #
  # @example Creating an explicitly datatyped literal
  #   value = RDF::Literal.new("2009-12-31", datatype: RDF::XSD.date)
  #   value.has_datatype?                            #=> true
  #   value.datatype                                 #=> RDF::XSD.date
  #
  # @example Creating an implicitly datatyped literal
  #   value = RDF::Literal.new(Date.today)
  #   value.has_datatype?                            #=> true
  #   value.datatype                                 #=> RDF::XSD.date
  #
  # @example Creating implicitly datatyped literals
  #   RDF::Literal.new(false).datatype               #=> XSD.boolean
  #   RDF::Literal.new(true).datatype                #=> XSD.boolean
  #   RDF::Literal.new(123).datatype                 #=> XSD.integer
  #   RDF::Literal.new(9223372036854775807).datatype #=> XSD.integer
  #   RDF::Literal.new(3.1415).datatype              #=> XSD.double
  #   RDF::Literal.new(Time.now).datatype            #=> XSD.time
  #   RDF::Literal.new(Date.new(2010)).datatype      #=> XSD.date
  #   RDF::Literal.new(DateTime.new(2010)).datatype  #=> XSD.dateTime
  #
  # @see http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal
  # @see http://www.w3.org/TR/rdf11-concepts/#section-Datatypes
  class Literal

  private
    @@subclasses       = [] # @private
    @@datatype_map     = nil # @private

    ##
    # @private
    # @return [void]
    def self.inherited(child)
      @@subclasses << child
      @@datatype_map = nil
      super
    end
  
  public

    require 'rdf/model/literal/numeric'
    require 'rdf/model/literal/boolean'
    require 'rdf/model/literal/decimal'
    require 'rdf/model/literal/integer'
    require 'rdf/model/literal/double'
    require 'rdf/model/literal/date'
    require 'rdf/model/literal/datetime'
    require 'rdf/model/literal/time'
    require 'rdf/model/literal/token'

    include RDF::Term

    ##
    # @private
    # Return Hash mapping from datatype URI to class
    def self.datatype_map
      @@datatype_map ||= Hash[
        @@subclasses
          .select {|klass| klass.const_defined?(:DATATYPE)}
          .map {|klass| [klass.const_get(:DATATYPE).to_s, klass]}
      ]
    end

    ##
    # @private
    # Return datatype class for uri, or nil if none is found
    def self.datatyped_class(uri)
      datatype_map[uri]
    end

    ##
    # @private
    def self.new(value, language: nil, datatype: nil, lexical: nil, validate: false, canonicalize: false, **options)
      raise ArgumentError, "datatype with language must be rdf:langString" if language && (datatype || RDF.langString).to_s != RDF.langString.to_s

      klass = case
        when !self.equal?(RDF::Literal)
          self # subclasses can be directly constructed without type dispatch
        when typed_literal = datatyped_class(datatype.to_s)
          typed_literal
        else case value
          when ::TrueClass  then RDF::Literal::Boolean
          when ::FalseClass then RDF::Literal::Boolean
          when ::Integer    then RDF::Literal::Integer
          when ::Float      then RDF::Literal::Double
          when ::BigDecimal then RDF::Literal::Decimal
          when ::DateTime   then RDF::Literal::DateTime
          when ::Date       then RDF::Literal::Date
          when ::Time       then RDF::Literal::Time # FIXME: Ruby's Time class can represent datetimes as well
          when ::Symbol     then RDF::Literal::Token
          else self
        end
      end
      literal = klass.allocate
      literal.send(:initialize, value, language: language, datatype: datatype, **options)
      literal.validate!     if validate
      literal.canonicalize! if canonicalize
      literal
    end

    TRUE  = RDF::Literal.new(true)
    FALSE = RDF::Literal.new(false)
    ZERO  = RDF::Literal.new(0)

    # @return [Symbol] The language tag (optional).
    attr_accessor :language

    # @return [URI] The XML Schema datatype URI (optional).
    attr_accessor :datatype

    ##
    # Literals without a datatype are given either xsd:string or rdf:langString
    # depending on if there is language
    #
    # @param  [Object] value
    # @param  [Symbol]  language (nil)
    #   Language is downcased to ensure proper matching
    # @param [String]  lexical (nil)
    #   Supplied lexical representation of this literal,
    #   otherwise it comes from transforming `value` to a string form..
    # @param [URI]     datatype (nil)
    # @param [Boolean] validate (false)
    # @param [Boolean] canonicalize (false)
    # @raise [ArgumentError]
    #   if there is a language and datatype is no rdf:langString
    #   or datatype is rdf:langString and there is no language
    # @see http://www.w3.org/TR/rdf11-concepts/#section-Graph-Literal
    # @see http://www.w3.org/TR/rdf11-concepts/#section-Datatypes
    # @see #to_s
    def initialize(value, language: nil, datatype: nil, lexical: nil, validate: false, canonicalize: false, **options)
      @object   = value.freeze
      @string   = lexical if lexical
      @string   = value if !defined?(@string) && value.is_a?(String)
      @string   = @string.encode(Encoding::UTF_8).freeze if @string
      @object   = @string if @string && @object.is_a?(String)
      @language = language.to_s.downcase.to_sym if language
      @datatype = RDF::URI(datatype).freeze if datatype
      @datatype ||= self.class.const_get(:DATATYPE) if self.class.const_defined?(:DATATYPE)
      @datatype ||= @language ? RDF.langString : RDF::XSD.string
      raise ArgumentError, "datatype of rdf:langString requires a language" if !@language && @datatype == RDF::langString
    end

    ##
    # Returns the value as a string.
    #
    # @return [String]
    def value
      @string || to_s
    end

    ##
    # @return [Object]
    def object
      defined?(@object) ? @object : value
    end

    ##
    # Returns `true`.
    #
    # @return [Boolean] `true` or `false`
    def literal?
      true
    end

    ##
    # Term compatibility according to SPARQL
    #
    # Compatibility of two arguments is defined as:
    # * The arguments are simple literals or literals typed as xsd:string
    # * The arguments are plain literals with identical language tags
    # * The first argument is a plain literal with language tag and the second argument is a simple literal or literal typed as xsd:string
    #
    # @example
    #     compatible?("abc"	"b")                         #=> true
    #     compatible?("abc"	"b"^^xsd:string)             #=> true
    #     compatible?("abc"^^xsd:string	"b")             #=> true
    #     compatible?("abc"^^xsd:string	"b"^^xsd:string) #=> true
    #     compatible?("abc"@en	"b")                     #=> true
    #     compatible?("abc"@en	"b"^^xsd:string)         #=> true
    #     compatible?("abc"@en	"b"@en)                  #=> true
    #     compatible?("abc"@fr	"b"@ja)                  #=> false
    #     compatible?("abc"	"b"@ja)                      #=> false
    #     compatible?("abc"	"b"@en)                      #=> false
    #     compatible?("abc"^^xsd:string	"b"@en)          #=> false
    #
    # @see http://www.w3.org/TR/sparql11-query/#func-arg-compatibility
    # @since 2.0
    def compatible?(other)
      return false unless other.literal? && plain? && other.plain?

      # * The arguments are simple literals or literals typed as xsd:string
      # * The arguments are plain literals with identical language tags
      # * The first argument is a plain literal with language tag and the second argument is a simple literal or literal typed as xsd:string
      has_language? ?
        (language == other.language || other.datatype == RDF::XSD.string) :
        other.datatype == RDF::XSD.string
    end

    ##
    # Returns a hash code for this literal.
    #
    # @return [Integer]
    def hash
      @hash ||= [to_s, datatype, language].hash
    end


    ##
    # Returns a hash code for the value.
    #
    # @return [Integer]
    def value_hash
      @value_hash ||= value.hash
    end

    ##
    # @private
    def freeze
      hash.freeze
      value_hash.freeze
      super
    end

    ##
    # Determins if `self` is the same term as `other`.
    #
    # @example
    #   RDF::Literal(1).eql?(RDF::Literal(1.0))  #=> false
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    def eql?(other)
      self.equal?(other) ||
        (self.class.eql?(other.class) &&
         self.value_hash == other.value_hash &&
         self.value.eql?(other.value) &&
         self.language.to_s.eql?(other.language.to_s) &&
         self.datatype.eql?(other.datatype))
    end

    ##
    # Returns `true` if this literal is equivalent to `other` (with type check).
    #
    # @example
    #   RDF::Literal(1) == RDF::Literal(1.0)     #=> true
    #
    # @param  [Object] other
    # @return [Boolean] `true` or `false`
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
    # @see http://www.w3.org/TR/rdf-concepts/#section-Literal-Equality
    def ==(other)
      case other
      when Literal
        case
        when self.eql?(other)
          true
        when self.has_language? && self.language.to_s == other.language.to_s
          # Literals with languages can compare if languages are identical
          self.value_hash == other.value_hash && self.value == other.value
        when self.simple? && other.simple?
          self.value_hash == other.value_hash && self.value == other.value
        when other.comperable_datatype?(self) || self.comperable_datatype?(other)
          # Comoparing plain with undefined datatypes does not generate an error, but returns false
          # From data-r2/expr-equal/eq-2-2.
          false
        else
          type_error("unable to determine whether #{self.inspect} and #{other.inspect} are equivalent")
        end
      when String
        self.simple? && self.value.eql?(other)
      else false
      end
    end
    alias_method :===, :==

    ##
    # Returns `true` if this is a plain literal. A plain literal
    # may have a language, but may not have a datatype. For
    # all practical purposes, this includes xsd:string literals
    # too.
    #
    # @return [Boolean] `true` or `false`
    # @see http://www.w3.org/TR/rdf-concepts/#dfn-plain-literal
    def plain?
      [RDF.langString, RDF::XSD.string].include?(datatype)
    end

    ##
    # Returns `true` if this is a simple literal.
    # A simple literal has no datatype or language.
    #
    # @return [Boolean] `true` or `false`
    # @see http://www.w3.org/TR/sparql11-query/#simple_literal
    def simple?
      datatype == RDF::XSD.string
    end

    ##
    # Returns `true` if this is a language-tagged literal.
    #
    # @return [Boolean] `true` or `false`
    # @see http://www.w3.org/TR/rdf-concepts/#dfn-plain-literal
    def has_language?
      datatype == RDF.langString
    end
    alias_method :language?, :has_language?

    ##
    # Returns `true` if this is a datatyped literal.
    #
    # For historical reasons, this excludes xsd:string and rdf:langString
    #
    # @return [Boolean] `true` or `false`
    # @see http://www.w3.org/TR/rdf-concepts/#dfn-typed-literal
    def has_datatype?
      !plain? && !language?
    end
    alias_method :datatype?,  :has_datatype?
    alias_method :typed?,     :has_datatype?
    alias_method :datatyped?, :has_datatype?

    ##
    # Returns `true` if the value adheres to the defined grammar of the
    # datatype.
    #
    # @return [Boolean] `true` or `false`
    # @since  0.2.1
    def valid?
      grammar = self.class.const_get(:GRAMMAR) rescue nil
      grammar.nil? || !!(value =~ grammar)
    end

    ##
    # Validates the value using {RDF::Value#valid?}, raising an error if the value is
    # invalid.
    #
    # @return [RDF::Literal] `self`
    # @raise  [ArgumentError] if the value is invalid
    # @since  0.2.1
    def validate!
      raise ArgumentError, "#{to_s.inspect} is not a valid <#{datatype.to_s}> literal" if invalid?
      self
    end

    ##
    # Returns `true` if the literal has a datatype and the comparison should
    # return false instead of raise a type error.
    #
    # This behavior is intuited from SPARQL data-r2/expr-equal/eq-2-2
    # @return [Boolean]
    def comperable_datatype?(other)
      return false unless self.plain? || self.has_language?

      case other
      when RDF::Literal::Numeric, RDF::Literal::Boolean,
           RDF::Literal::Date, RDF::Literal::Time, RDF::Literal::DateTime
        # Invald types can be compared without raising a TypeError if literal has a language (open-eq-08)
        !other.valid? && self.has_language?
      else
        # An unknown datatype may not be used for comparison, unless it has a language? (open-eq-8)
        self.has_language?
      end
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # Subclasses should override this as needed and appropriate.
    #
    # @return [RDF::Literal] `self`
    # @since  0.3.0
    def canonicalize!
      self
    end

    ##
    # Returns the literal, first removing all whitespace on both ends of the value, and then changing remaining consecutive whitespace groups into one space each.
    #
    # Note that it handles both ASCII and Unicode whitespace.
    #
    # @see [String#squish](http://apidock.com/rails/String/squish)
    # @return [RDF::Literal] a new literal based on `self`.
    def squish(*other_string)
      self.dup.squish!
    end

    ##
    # Performs a destructive {#squish}.
    #
    # @see [String#squish!](http://apidock.com/rails/String/squish%21)
    # @return self
    def squish!
      @string = value.
        gsub(/\A[[:space:]]+/, '').
        gsub(/[[:space:]]+\z/, '').
        gsub(/[[:space:]]+/, ' ')
      self
    end

    ##
    # Escape a literal using ECHAR escapes.
    #
    #    ECHAR ::= '\' [tbnrf"'\]
    #
    # @note N-Triples only requires '\"\n\r' to be escaped.
    #
    # @param  [String] string
    # @return [String]
    # @see RDF::Term#escape
    def escape(string)
      string.gsub('\\', '\\\\').
             gsub("\t", '\\t').
             gsub("\b", '\\b').
             gsub("\n", '\\n').
             gsub("\r", '\\r').
             gsub("\f", '\\f').
             gsub('"', '\\"').
             freeze
    end

    ##
    # Returns the value as a string.
    #
    # @return [String]
    def to_s
      @object.to_s.freeze
    end

    ##
    # Returns a human-readable value for the literal
    #
    # @return [String]
    # @since 1.1.6
    def humanize(lang = :en)
      to_s.freeze
    end

    ##
    # Returns a developer-friendly representation of `self`.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, RDF::NTriples.serialize(self))
    end

    protected

    ##
    # @overload #to_str
    #   This method is implemented when the datatype is `xsd:string` or `rdf:langString`
    #   @return [String]
    def method_missing(name, *args)
      case name
      when :to_str
        return to_s if @datatype == RDF.langString || @datatype == RDF::XSD.string
      end
      super
    end

    def respond_to_missing?(name, include_private = false)
      case name
      when :to_str
        return true if @datatype == RDF.langString || @datatype == RDF::XSD.string
      end
      super
    end
  end # Literal
end # RDF
