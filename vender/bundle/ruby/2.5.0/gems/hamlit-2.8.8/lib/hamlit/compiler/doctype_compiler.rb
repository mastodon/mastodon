# frozen_string_literal: true
module Hamlit
  class Compiler
    class DoctypeCompiler
      def initialize(options = {})
        @format = options[:format]
      end

      def compile(node)
        case node.value[:type]
        when 'xml'
          xml_doctype
        when ''
          html_doctype(node)
        else
          [:html, :doctype, node.value[:type]]
        end
      end

      private

      def html_doctype(node)
        version = node.value[:version] || :transitional
        case @format
        when :xhtml
          [:html, :doctype, version]
        when :html4
          [:html, :doctype, :transitional]
        when :html5
          [:html, :doctype, :html]
        else
          [:html, :doctype, @format]
        end
      end

      def xml_doctype
        case @format
        when :xhtml
          [:static, "<?xml version='1.0' encoding='utf-8' ?>\n"]
        else
          [:multi]
        end
      end
    end
  end
end
