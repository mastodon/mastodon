# -*- encoding: utf-8 -*-
module RDF::NTriples
  ##
  # N-Triples parser.
  #
  # @example Obtaining an NTriples reader class
  #   RDF::Reader.for(:ntriples)     #=> RDF::NTriples::Reader
  #   RDF::Reader.for("etc/doap.nt")
  #   RDF::Reader.for(file_name:      "etc/doap.nt")
  #   RDF::Reader.for(file_extension: "nt")
  #   RDF::Reader.for(content_type:   "application/n-triples")
  #
  # @example Parsing RDF statements from an NTriples file
  #   RDF::NTriples::Reader.open("etc/doap.nt") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @example Parsing RDF statements from an NTriples string
  #   data = StringIO.new(File.read("etc/doap.nt"))
  #   RDF::NTriples::Reader.new(data) do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @see http://www.w3.org/TR/rdf-testcases/#ntriples
  # @see http://www.w3.org/TR/n-triples/
  class Reader < RDF::Reader
    include RDF::Util::Logger
    format RDF::NTriples::Format

    # @see http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    ESCAPE_CHARS    = ["\b", "\f", "\t", "\n", "\r", "\"", "\\"].freeze
    UCHAR4          = /\\u([0-9A-Fa-f]{4,4})/.freeze
    UCHAR8          = /\\U([0-9A-Fa-f]{8,8})/.freeze
    UCHAR           = Regexp.union(UCHAR4, UCHAR8).freeze


    # Terminals from rdf-turtle.
    #
    # @see http://www.w3.org/TR/n-triples/
    # @see http://www.w3.org/TR/turtle/
    ##
    # Unicode regular expressions.
    U_CHARS1         = Regexp.compile(<<-EOS.gsub(/\s+/, ''))
                         [\\u00C0-\\u00D6]|[\\u00D8-\\u00F6]|[\\u00F8-\\u02FF]|
                         [\\u0370-\\u037D]|[\\u037F-\\u1FFF]|[\\u200C-\\u200D]|
                         [\\u2070-\\u218F]|[\\u2C00-\\u2FEF]|[\\u3001-\\uD7FF]|
                         [\\uF900-\\uFDCF]|[\\uFDF0-\\uFFFD]|[\\u{10000}-\\u{EFFFF}]
                       EOS
    U_CHARS2         = Regexp.compile("\\u00B7|[\\u0300-\\u036F]|[\\u203F-\\u2040]").freeze
    IRI_RANGE        = Regexp.compile("[[^<>\"{}\|\^`\\\\]&&[^\\x00-\\x20]]").freeze

    # 163s
    PN_CHARS_BASE        = /[A-Z]|[a-z]|#{U_CHARS1}/.freeze
    # 164s
    PN_CHARS_U           = /_|#{PN_CHARS_BASE}/.freeze
    # 166s
    PN_CHARS             = /-|[0-9]|#{PN_CHARS_U}|#{U_CHARS2}/.freeze
    # 159s
    ECHAR                = /\\[tbnrf\\"]/.freeze
    # 18
    IRIREF               = /<((?:#{IRI_RANGE}|#{UCHAR})*)>/.freeze
    # 141s
    BLANK_NODE_LABEL     = /_:((?:[0-9]|#{PN_CHARS_U})(?:(?:#{PN_CHARS}|\.)*#{PN_CHARS})?)/.freeze
    # 144s
    LANGTAG              = /@([a-zA-Z]+(?:-[a-zA-Z0-9]+)*)/.freeze
    # 22
    STRING_LITERAL_QUOTE = /"((?:[^\"\\\n\r]|#{ECHAR}|#{UCHAR})*)"/.freeze

    # @see http://www.w3.org/TR/rdf-testcases/#ntrip_grammar
    COMMENT               = /^#\s*(.*)$/.freeze
    NODEID                = /^#{BLANK_NODE_LABEL}/.freeze
    URIREF                = /^#{IRIREF}/.freeze
    LITERAL_PLAIN         = /^#{STRING_LITERAL_QUOTE}/.freeze
    LITERAL_WITH_LANGUAGE = /^#{STRING_LITERAL_QUOTE}#{LANGTAG}/.freeze
    LITERAL_WITH_DATATYPE = /^#{STRING_LITERAL_QUOTE}\^\^#{IRIREF}/.freeze
    DATATYPE_URI          = /^\^\^#{IRIREF}/.freeze
    LITERAL               = Regexp.union(LITERAL_WITH_LANGUAGE, LITERAL_WITH_DATATYPE, LITERAL_PLAIN).freeze
    SUBJECT               = Regexp.union(URIREF, NODEID).freeze
    PREDICATE             = Regexp.union(URIREF).freeze
    OBJECT                = Regexp.union(URIREF, NODEID, LITERAL).freeze
    END_OF_STATEMENT      = /^\s*\.\s*(?:#.*)?$/.freeze

    ##
    # Reconstructs an RDF value from its serialized N-Triples
    # representation.
    #
    # @param  [String] input
    # @param [{Symbol => Object}] options
    #   From {RDF::Reader#initialize}
    # @option options  [RDF::Util::Logger] :logger ([])
    # @return [RDF::Term]
    def self.unserialize(input, **options)
      case input
        when nil then nil
        else self.new(input, {logger: []}.merge(options)).read_value
      end
    end

    ##
    # (see unserialize)
    # @return [RDF::Resource]
    def self.parse_subject(input, **options)
      parse_uri(input, options) || parse_node(input, options)
    end

    ##
    # (see unserialize)
    # @return [RDF::URI]
    def self.parse_predicate(input, *options)
      parse_uri(input, intern: true)
    end

    ##
    # (see unserialize)
    def self.parse_object(input, **options)
      parse_uri(input, options) || parse_node(input, options) || parse_literal(input, options)
    end

    ##
    # (see unserialize)
    # @return [RDF::Node]
    def self.parse_node(input, **options)
      if input =~ NODEID
        RDF::Node.new($1)
      end
    end

    ##
    # (see unserialize)
    # @param [Boolean] intern (false) Use Interned URI
    # @return [RDF::URI]
    def self.parse_uri(input, intern: false, **options)
      if input =~ URIREF
        uri_str = unescape($1)
        RDF::URI.send(intern ? :intern : :new, unescape($1))
      end
    end

    ##
    # (see unserialize)
    # @return [RDF::Literal]
    def self.parse_literal(input, **options)
      case input
        when LITERAL_WITH_LANGUAGE
          RDF::Literal.new(unescape($1), language: $4)
        when LITERAL_WITH_DATATYPE
          RDF::Literal.new(unescape($1), datatype: $4)
        when LITERAL_PLAIN
          RDF::Literal.new(unescape($1))
      end
    end

    ##
    # @param  [String] string
    # @return [String]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    # @see    http://blog.grayproductions.net/articles/understanding_m17n
    # @see    http://yehudakatz.com/2010/05/17/encodings-unabridged/
    def self.unescape(string)
      string = string.dup.force_encoding(Encoding::UTF_8)

      # Decode \t|\n|\r|\"|\\ character escapes:
      ESCAPE_CHARS.each { |escape| string.gsub!(escape.inspect[1...-1], escape) }

      # Decode \uXXXX and \UXXXXXXXX code points:
      string.gsub!(UCHAR) do
        [($1 || $2).hex].pack('U*')
      end

      string
    end

    ##
    # @return [RDF::Term]
    def read_value
      begin
        read_statement
      rescue RDF::ReaderError
        value = read_uriref || read_node || read_literal
        log_recover
        value
      end
    end

    ##
    # @return [Array]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_grammar
    def read_triple
      loop do
        readline.strip! # EOFError thrown on end of input
        line = @line    # for backtracking input in case of parse error

        begin
          unless blank? || read_comment
            subject   = read_uriref || read_node || fail_subject
            predicate = read_uriref(intern: true) || fail_predicate
            object    = read_uriref || read_node || read_literal || fail_object

            if validate? && !read_eos
              log_error("Expected end of statement (found: #{current_line.inspect})", lineno: lineno, exception: RDF::ReaderError)
            end
            return [subject, predicate, object]
          end
        rescue RDF::ReaderError => e
          @line = line  # this allows #read_value to work
          raise e
        end
      end
    end

    ##
    # @return [Boolean]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_grammar (comment)
    def read_comment
      match(COMMENT)
    end

    ##
    # @param [Boolean] intern (false) Use Interned Node
    # @return [RDF::URI]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_grammar (uriref)
    def read_uriref(intern: false, **options)
      if uri_str = match(URIREF)
        uri_str = self.class.unescape(uri_str)
        uri = RDF::URI.send(intern? && intern ? :intern : :new, uri_str)
        uri.validate!     if validate?
        uri.canonicalize! if canonicalize?
        uri
      end
    rescue ArgumentError => e
      log_error("Invalid URI (found: \"<#{uri_str}>\")", lineno: lineno, token: "<#{uri_str}>", exception: RDF::ReaderError)
    end

    ##
    # @return [RDF::Node]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_grammar (nodeID)
    def read_node
       if node_id = match(NODEID)
        @nodes ||= {}
        @nodes[node_id] ||= RDF::Node.new(node_id)
      end
    end

    ##
    # @return [RDF::Literal]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_grammar (literal)
    def read_literal
      if literal_str = match(LITERAL_PLAIN)
        literal_str = self.class.unescape(literal_str)
        literal = case
          when language = match(LANGTAG)
            RDF::Literal.new(literal_str, language: language)
          when datatype = match(/^(\^\^)/) # FIXME
            RDF::Literal.new(literal_str, datatype: read_uriref || fail_object)
          else
            RDF::Literal.new(literal_str) # plain string literal
        end
        literal.validate!     if validate?
        literal.canonicalize! if canonicalize?
        literal
      end
    end

    ##
    # @return [Boolean]
    # @see http://www.w3.org/TR/rdf-testcases/#ntrip_grammar (triple)
    def read_eos
      match(END_OF_STATEMENT)
    end
  end # Reader
end # RDF::NTriples
