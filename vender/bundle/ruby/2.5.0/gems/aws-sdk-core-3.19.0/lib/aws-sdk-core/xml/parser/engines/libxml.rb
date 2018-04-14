require 'libxml'

module Aws
  module Xml
    class Parser
      class LibxmlEngine

        include LibXML::XML::SaxParser::Callbacks

        def initialize(stack)
          @stack = stack
        end

        def parse(xml)
          parser = ::LibXML::XML::SaxParser.string(xml)
          parser.callbacks = self
          parser.parse
        end

        def on_start_element_ns(element_name, attributes, prefix = nil, uri = nil, ns = {})
          # libxml-ruby does not provide a mapping from element attribute
          # names to their qname prefixes. The following code line assumes
          # that if a attribute ns is defined it applies to all attributes.
          # This is necessary to support parsing S3 Object ACL Grantees.
          # qnames are not used by any other AWS attribute. Also, new
          # services are using JSON, limiting the possible blast radius
          # of this patch.
          attr_ns_prefix = ns.keys.first
          @stack.start_element(element_name)
          attributes.each do |attr_name, attr_value|
            attr_name = "#{attr_ns_prefix}:#{attr_name}" if attr_ns_prefix
            @stack.attr(attr_name, attr_value)
          end
        end

        def on_end_element_ns(*ignored)
          @stack.end_element
        end

        def on_characters(chars)
          @stack.text(chars)
        end

        def on_error(msg)
          @stack.error(msg)
        end

      end
    end
  end
end
