module Nokogiri
  module XML
    module SAX
      ###
      # This parser is a SAX style parser that reads it's input as it
      # deems necessary.  The parser takes a Nokogiri::XML::SAX::Document,
      # an optional encoding, then given an XML input, sends messages to
      # the Nokogiri::XML::SAX::Document.
      #
      # Here is an example of using this parser:
      #
      #   # Create a subclass of Nokogiri::XML::SAX::Document and implement
      #   # the events we care about:
      #   class MyDoc < Nokogiri::XML::SAX::Document
      #     def start_element name, attrs = []
      #       puts "starting: #{name}"
      #     end
      #
      #     def end_element name
      #       puts "ending: #{name}"
      #     end
      #   end
      #
      #   # Create our parser
      #   parser = Nokogiri::XML::SAX::Parser.new(MyDoc.new)
      #
      #   # Send some XML to the parser
      #   parser.parse(File.open(ARGV[0]))
      #
      # For more information about SAX parsers, see Nokogiri::XML::SAX.  Also
      # see Nokogiri::XML::SAX::Document for the available events.
      class Parser
        class Attribute < Struct.new(:localname, :prefix, :uri, :value)
        end

        # Encodinds this parser supports
        ENCODINGS = {
          'NONE'        => 0, # No char encoding detected
          'UTF-8'       => 1, # UTF-8
          'UTF16LE'     => 2, # UTF-16 little endian
          'UTF16BE'     => 3, # UTF-16 big endian
          'UCS4LE'      => 4, # UCS-4 little endian
          'UCS4BE'      => 5, # UCS-4 big endian
          'EBCDIC'      => 6, # EBCDIC uh!
          'UCS4-2143'   => 7, # UCS-4 unusual ordering
          'UCS4-3412'   => 8, # UCS-4 unusual ordering
          'UCS2'        => 9, # UCS-2
          'ISO-8859-1'  => 10, # ISO-8859-1 ISO Latin 1
          'ISO-8859-2'  => 11, # ISO-8859-2 ISO Latin 2
          'ISO-8859-3'  => 12, # ISO-8859-3
          'ISO-8859-4'  => 13, # ISO-8859-4
          'ISO-8859-5'  => 14, # ISO-8859-5
          'ISO-8859-6'  => 15, # ISO-8859-6
          'ISO-8859-7'  => 16, # ISO-8859-7
          'ISO-8859-8'  => 17, # ISO-8859-8
          'ISO-8859-9'  => 18, # ISO-8859-9
          'ISO-2022-JP' => 19, # ISO-2022-JP
          'SHIFT-JIS'   => 20, # Shift_JIS
          'EUC-JP'      => 21, # EUC-JP
          'ASCII'       => 22, # pure ASCII
        }

        # The Nokogiri::XML::SAX::Document where events will be sent.
        attr_accessor :document

        # The encoding beings used for this document.
        attr_accessor :encoding

        # Create a new Parser with +doc+ and +encoding+
        def initialize doc = Nokogiri::XML::SAX::Document.new, encoding = 'UTF-8'
          @encoding = check_encoding(encoding)
          @document = doc
          @warned   = false
        end

        ###
        # Parse given +thing+ which may be a string containing xml, or an
        # IO object.
        def parse thing, &block
          if thing.respond_to?(:read) && thing.respond_to?(:close)
            parse_io(thing, &block)
          else
            parse_memory(thing, &block)
          end
        end

        ###
        # Parse given +io+
        def parse_io io, encoding = 'ASCII'
          @encoding = check_encoding(encoding)
          ctx = ParserContext.io(io, ENCODINGS[@encoding])
          yield ctx if block_given?
          ctx.parse_with self
        end

        ###
        # Parse a file with +filename+
        def parse_file filename
          raise ArgumentError unless filename
          raise Errno::ENOENT unless File.exist?(filename)
          raise Errno::EISDIR if File.directory?(filename)
          ctx = ParserContext.file filename
          yield ctx if block_given?
          ctx.parse_with self
        end

        def parse_memory data
          ctx = ParserContext.memory data
          yield ctx if block_given?
          ctx.parse_with self
        end

        private
        def check_encoding(encoding)
          encoding.upcase.tap do |enc|
            raise ArgumentError.new("'#{enc}' is not a valid encoding") unless ENCODINGS[enc]
          end
        end
      end
    end
  end
end
