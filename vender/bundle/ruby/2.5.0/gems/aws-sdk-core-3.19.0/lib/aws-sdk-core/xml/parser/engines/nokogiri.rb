require 'nokogiri'

module Aws
  module Xml
    class Parser
      class NokogiriEngine

        def initialize(stack)
          @stack = stack
        end

        def parse(xml)
          Nokogiri::XML::SAX::Parser.new(self).parse(xml)
        end

        def xmldecl(*args); end
        def start_document; end
        def end_document; end
        def comment(*args); end

        def start_element_namespace(element_name, attributes = [], *ignored)
          @stack.start_element(element_name)
          attributes.each do |attr|
            name = attr.localname
            name = "#{attr.prefix}:#{name}" if attr.prefix
            @stack.attr(name, attr.value)
          end
        end

        def characters(chars)
          @stack.text(chars)
        end

        def end_element_namespace(*ignored)
          @stack.end_element
        end

        def error(msg)
          @stack.error(msg)
        end

      end
    end
  end
end
