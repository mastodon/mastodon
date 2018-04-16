# frozen_string_literal: true
module Hamlit
  class Filters
    class Css < TextBase
      def compile(node)
        case @format
        when :xhtml
          compile_xhtml(node)
        else
          compile_html(node)
        end
      end

      private

      def compile_html(node)
        temple = [:multi]
        temple << [:static, "<style>\n"]
        compile_text!(temple, node, '  ')
        temple << [:static, "\n</style>"]
        temple
      end

      def compile_xhtml(node)
        temple = [:multi]
        temple << [:static, "<style type='text/css'>\n  /*<![CDATA[*/\n"]
        compile_text!(temple, node, '    ')
        temple << [:static, "\n  /*]]>*/\n</style>"]
        temple
      end
    end
  end
end
