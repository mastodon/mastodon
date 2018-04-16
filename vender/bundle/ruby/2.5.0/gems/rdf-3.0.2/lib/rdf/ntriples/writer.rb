# -*- encoding: utf-8 -*-
module RDF::NTriples
  ##
  # N-Triples serializer.
  #
  # Output is serialized for UTF-8, to serialize as ASCII
  # (with) unicode escapes, set encoding: Encoding::ASCII as
  # an option to {RDF::NTriples::Writer#initialize}.
  #
  # @example Obtaining an NTriples writer class
  #   RDF::Writer.for(:ntriples)     #=> RDF::NTriples::Writer
  #   RDF::Writer.for("etc/test.nt")
  #   RDF::Writer.for(file_name:      "etc/test.nt")
  #   RDF::Writer.for(file_extension: "nt")
  #   RDF::Writer.for(content_type:   "application/n-triples")
  #
  # @example Serializing RDF statements into an NTriples file
  #   RDF::NTriples::Writer.open("etc/test.nt") do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @example Serializing RDF statements into an NTriples string
  #   RDF::NTriples::Writer.buffer do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @example Serializing RDF statements into an NTriples string with escaped UTF-8
  #   RDF::NTriples::Writer.buffer(encoding: Encoding::ASCII) do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @see http://www.w3.org/TR/rdf-testcases/#ntriples
  # @see http://www.w3.org/TR/n-triples/
  class Writer < RDF::Writer
    include RDF::Util::Logger
    format RDF::NTriples::Format

    # @see http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    ESCAPE_PLAIN = /\A[\x20-\x21\x23-#{Regexp.escape '['}#{Regexp.escape ']'}-\x7E]*\z/m.freeze
    ESCAPE_PLAIN_U = /\A(?:#{Reader::IRI_RANGE}|#{Reader::UCHAR})*\z/.freeze

    ##
    # Escape Literal and URI content. If encoding is ASCII, all unicode
    # is escaped, otherwise only ASCII characters that must be escaped are
    # escaped.
    #
    # @param  [String] string
    # @param  [Encoding] encoding
    # @return [String]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    def self.escape(string, encoding = nil)
      ret = case
        when string =~ ESCAPE_PLAIN # a shortcut for the simple case
          string
        when string.ascii_only?
          StringIO.open do |buffer|
            buffer.set_encoding(Encoding::ASCII)
            string.each_byte { |u| buffer << escape_ascii(u, encoding) }
            buffer.string
          end
        when encoding && encoding != Encoding::ASCII
          # Not encoding UTF-8 characters
          StringIO.open do |buffer|
            buffer.set_encoding(encoding)
            string.each_char do |u|
              buffer << case u.ord
              when (0x00..0x7F)
                escape_ascii(u, encoding)
              else
                u
              end
            end
            buffer.string
          end
        else
          # Encode ASCII && UTF-8 characters
          StringIO.open do |buffer|
            buffer.set_encoding(Encoding::ASCII)
            string.each_codepoint { |u| buffer << escape_unicode(u, encoding) }
            buffer.string
          end
      end
      encoding ? ret.encode(encoding) : ret
    end

    ##
    # Escape ascii and unicode characters.
    # If encoding is UTF_8, only ascii characters are escaped.
    #
    # @param  [Integer, #ord] u
    # @param  [Encoding] encoding
    # @return [String]
    # @raise  [ArgumentError] if `u` is not a valid Unicode codepoint
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    def self.escape_unicode(u, encoding)
      case (u = u.ord)
        when (0x00..0x7F)        # ASCII 7-bit
          escape_ascii(u, encoding)
        when (0x80..0xFFFF)      # Unicode BMP
          escape_utf16(u)
        when (0x10000..0x10FFFF) # Unicode
          escape_utf32(u)
        else
          raise ArgumentError.new("expected a Unicode codepoint in (0x00..0x10FFFF), but got 0x#{u.to_s(16)}")
      end
    end

    ##
    # Standard ASCII escape sequences. If encoding is ASCII, use Test-Cases
    # sequences, otherwise, assume the test-cases escape sequences. Otherwise,
    # the N-Triples recommendation includes `\b` and `\f` escape sequences.
    #
    # @param  [Integer, #ord] u
    # @return [String]
    # @raise  [ArgumentError] if `u` is not a valid Unicode codepoint
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    # @see    http://www.w3.org/TR/n-triples/
    def self.escape_ascii(u, encoding)
      case (u = u.ord)
        when (0x00..0x07) then escape_utf16(u)
        when (0x08)       then (encoding && encoding == Encoding::ASCII ? escape_utf16(u) : "\\b")
        when (0x09)       then "\\t"
        when (0x0A)       then "\\n"
        when (0x0B)       then escape_utf16(u)
        when (0x0C)       then (encoding && encoding == Encoding::ASCII ? escape_utf16(u) : "\\f")
        when (0x0D)       then "\\r"
        when (0x0E..0x1F) then escape_utf16(u)
        when (0x22)       then "\\\""
        when (0x5C)       then "\\\\"
        when (0x7F)       then escape_utf16(u)
        when (0x00..0x7F) then u.chr
        else
          raise ArgumentError.new("expected an ASCII character in (0x00..0x7F), but got 0x#{u.to_s(16)}")
      end
    end

    ##
    # @param  [Integer, #ord] u
    # @return [String]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    def self.escape_utf16(u)
      sprintf("\\u%04X", u.ord)
    end

    ##
    # @param  [Integer, #ord] u
    # @return [String]
    # @see    http://www.w3.org/TR/rdf-testcases/#ntrip_strings
    def self.escape_utf32(u)
      sprintf("\\U%08X", u.ord)
    end

    ##
    # Returns the serialized N-Triples representation of the given RDF
    # value.
    #
    # @param  [RDF::Value] value
    # @return [String]
    # @raise  [ArgumentError] if `value` is not an `RDF::Statement` or `RDF::Term`
    def self.serialize(value)
      writer = self.new
      case value
        when nil then nil
        when FalseClass then value.to_s
        when RDF::Statement
          writer.format_statement(value) + "\n"
        when RDF::Term
          writer.format_term(value)
        else
          raise ArgumentError, "expected an RDF::Statement or RDF::Term, but got #{value.inspect}"
      end
    end

    ##
    # Initializes the writer.
    #
    # @param  [IO, File] output
    #   the output stream
    # @param [Boolean]  validate (true)
    #   whether to validate terms when serializing
    # @param  [Hash{Symbol => Object}] options ({})
    #   any additional options. See {RDF::Writer#initialize}
    # @yield  [writer] `self`
    # @yieldparam  [RDF::Writer] writer
    # @yieldreturn [void]
    def initialize(output = $stdout, validate: true, **options, &block)
      super
    end

    ##
    # Outputs an N-Triples comment line.
    #
    # @param  [String] text
    # @return [void]
    def write_comment(text)
      puts "# #{text.chomp}" # TODO: correctly output multi-line comments
    end

    ##
    # Outputs the N-Triples representation of a triple.
    #
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI]      predicate
    # @param  [RDF::Term]     object
    # @return [void]
    def write_triple(subject, predicate, object)
      puts format_triple(subject, predicate, object, @options)
    end

    ##
    # Returns the N-Triples representation of a statement.
    #
    # @param  [RDF::Statement] statement
    # @param  [Hash{Symbol => Object}] options ({})
    # @return [String]
    def format_statement(statement, **options)
      format_triple(*statement.to_triple, **options)
    end

    ##
    # Returns the N-Triples representation of a triple.
    #
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI]      predicate
    # @param  [RDF::Term]     object
    # @param  [Hash{Symbol => Object}] options ({})
    # @return [String]
    def format_triple(subject, predicate, object, **options)
      "%s %s %s ." % [subject, predicate, object].map { |value| format_term(value, **options) }
    end

    ##
    # Returns the N-Triples representation of a blank node.
    #
    # @param  [RDF::Node] node
    # @param [Boolean] unique_bnodes (false)
    #   Serialize node using unique identifier, rather than any used to create the node.
    # @param  [Hash{Symbol => Object}] options ({})
    # @return [String]
    def format_node(node, unique_bnodes: false, **options)
      unique_bnodes ? node.to_unique_base : node.to_s
    end

    ##
    # Returns the N-Triples representation of a URI reference using write encoding.
    #
    # @param  [RDF::URI] uri
    # @param  [Hash{Symbol => Object}] options ({})
    # @return [String]
    def format_uri(uri, **options)
      string = uri.to_s
      iriref = case
        when string =~ ESCAPE_PLAIN_U # a shortcut for the simple case
          string
        when string.ascii_only? || (encoding && encoding != Encoding::ASCII)
          StringIO.open do |buffer|
            buffer.set_encoding(encoding)
            string.each_char do |u|
              buffer << case u.ord
                when (0x00..0x20) then self.class.escape_utf16(u)
                when 0x22, 0x3c, 0x3e, 0x5c, 0x5e, 0x60, 0x7b, 0x7c, 0x7d # <>"{}|`\
                  self.class.escape_utf16(u)
                else u
              end
            end
            buffer.string
          end
        else
          # Encode ASCII && UTF-8/16 characters
          StringIO.open do |buffer|
            buffer.set_encoding(Encoding::ASCII)
            string.each_byte do |u|
              buffer << case u
                when (0x00..0x20) then self.class.escape_utf16(u)
                when 0x22, 0x3c, 0x3e, 0x5c, 0x5e, 0x60, 0x7b, 0x7c, 0x7d # <>"{}|`\
                  self.class.escape_utf16(u)
                when (0x80..0xFFFF)                then self.class.escape_utf16(u)
                when (0x10000..0x10FFFF)           then self.class.escape_utf32(u)
                else u
              end
            end
            buffer.string
          end
      end
      encoding ? "<#{iriref}>".encode(encoding) : "<#{iriref}>"
    end

    ##
    # Returns the N-Triples representation of a literal.
    #
    # @param  [RDF::Literal, String, #to_s] literal
    # @param  [Hash{Symbol => Object}] options ({})
    # @return [String]
    def format_literal(literal, **options)
      case literal
        when RDF::Literal
          # Note, escaping here is more robust than in Term
          text = quoted(escaped(literal.value))
          text << "@#{literal.language}" if literal.has_language?
          text << "^^<#{uri_for(literal.datatype)}>" if literal.has_datatype?
          text
        else
          quoted(escaped(literal.to_s))
      end
    end

    ##
    # @private
    def escaped(string)
      self.class.escape(string, encoding)
    end
  end
end
