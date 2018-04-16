module Nokogiri
  module HTML
    ###
    # Nokogiri lets you write a SAX parser to process HTML but get HTML
    # correction features.
    #
    # See Nokogiri::HTML::SAX::Parser for a basic example of using a
    # SAX parser with HTML.
    #
    # For more information on SAX parsers, see Nokogiri::XML::SAX
    module SAX
      ###
      # This class lets you perform SAX style parsing on HTML with HTML
      # error correction.
      #
      # Here is a basic usage example:
      #
      #   class MyDoc < Nokogiri::XML::SAX::Document
      #     def start_element name, attributes = []
      #       puts "found a #{name}"
      #     end
      #   end
      #
      #   parser = Nokogiri::HTML::SAX::Parser.new(MyDoc.new)
      #   parser.parse(File.read(ARGV[0], mode: 'rb'))
      #
      # For more information on SAX parsers, see Nokogiri::XML::SAX
      class Parser < Nokogiri::XML::SAX::Parser
        ###
        # Parse html stored in +data+ using +encoding+
        def parse_memory data, encoding = 'UTF-8'
          raise ArgumentError unless data
          return unless data.length > 0
          ctx = ParserContext.memory(data, encoding)
          yield ctx if block_given?
          ctx.parse_with self
        end

        ###
        # Parse given +io+
        def parse_io io, encoding = 'UTF-8'
          check_encoding(encoding)
          @encoding = encoding
          ctx = ParserContext.io(io, ENCODINGS[encoding])
          yield ctx if block_given?
          ctx.parse_with self
        end

        ###
        # Parse a file with +filename+
        def parse_file filename, encoding = 'UTF-8'
          raise ArgumentError unless filename
          raise Errno::ENOENT unless File.exist?(filename)
          raise Errno::EISDIR if File.directory?(filename)
          ctx = ParserContext.file(filename, encoding)
          yield ctx if block_given?
          ctx.parse_with self
        end
      end
    end
  end
end
