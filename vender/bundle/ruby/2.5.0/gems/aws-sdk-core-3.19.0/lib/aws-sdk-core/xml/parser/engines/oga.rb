require 'oga'

module Aws
  module Xml
    class Parser
      class OgaEngine

        def initialize(stack)
          @stack = stack
          @depth = 0
        end

        def parse(xml)
          Oga.sax_parse_xml(self, xml, strict:true)
        rescue LL::ParserError => error
          raise ParsingError.new(error.message, nil, nil)
        end

        def on_element(namespace, name, attrs = {})
          @depth += 1
          @stack.start_element(name)
          attrs.each do |attr|
            @stack.attr(*attr)
          end
        end

        def on_text(value)
          @stack.text(value) if @depth > 0
        end

        def after_element(_, _)
          @stack.end_element
          @depth -= 1
        end

      end
    end
  end
end
