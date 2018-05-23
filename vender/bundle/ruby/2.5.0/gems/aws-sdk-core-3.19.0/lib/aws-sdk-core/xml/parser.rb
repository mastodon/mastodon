module Aws
  # @api private
  module Xml
    # A SAX-style XML parser that uses a shape context to handle types.
    class Parser

      # @param [Seahorse::Model::ShapeRef] rules
      def initialize(rules, options = {})
        @rules = rules
        @engine = options[:engine] || self.class.engine
      end

      # Parses the XML document, returning a parsed structure.
      #
      # If you pass a block, this will yield for XML
      # elements that are not modeled in the rules given
      # to the constructor.
      #
      #   parser.parse(xml) do |path, value|
      #     puts "uhandled: #{path.join('/')} - #{value}"
      #   end
      #
      # The purpose of the unhandled callback block is to
      # allow callers to access values such as the EC2
      # request ID that are part of the XML body but not
      # part of the operation result.
      #
      # @param [String] xml An XML document string to parse.
      # @param [Structure] target (nil)
      # @return [Structure]
      def parse(xml, target = nil, &unhandled_callback)
        xml = '<xml/>' if xml.nil? or xml.empty?
        stack = Stack.new(@rules, target, &unhandled_callback)
        @engine.new(stack).parse(xml.to_s)
        stack.result
      end

      class << self

        # @param [Symbol,Class] engine
        #   Must be one of the following values:
        #
        #   * :ox
        #   * :oga
        #   * :libxml
        #   * :nokogiri
        #   * :rexml
        #
        def engine= engine
          @engine = Class === engine ? engine : load_engine(engine)
        end

        # @return [Class] Returns the default parsing engine.
        #   One of:
        #
        #   * {OxEngine}
        #   * {OgaEngine}
        #   * {LibxmlEngine}
        #   * {NokogiriEngine}
        #   * {RexmlEngine}
        #
        def engine
          set_default_engine unless @engine
          @engine
        end

        def set_default_engine
          [:ox, :oga, :libxml, :nokogiri, :rexml].each do |name|
            @engine ||= try_load_engine(name)
          end
        end

        private

        def load_engine(name)
          require "aws-sdk-core/xml/parser/engines/#{name}"
          const_name = name[0].upcase + name[1..-1] + 'Engine'
          const_get(const_name)
        end

        def try_load_engine(name)
          load_engine(name)
        rescue LoadError
          false
        end

      end

      set_default_engine

    end
  end
end
