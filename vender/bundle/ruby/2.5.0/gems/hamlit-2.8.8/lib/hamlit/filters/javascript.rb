# frozen_string_literal: true
module Hamlit
  class Filters
    class Javascript < TextBase
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
        temple << [:static, "<script>\n"]
        compile_text!(temple, node, '  ')
        temple << [:static, "\n</script>"]
        temple
      end

      def compile_xhtml(node)
        temple = [:multi]
        temple << [:static, "<script type='text/javascript'>\n  //<![CDATA[\n"]
        compile_text!(temple, node, '    ')
        temple << [:static, "\n  //]]>\n</script>"]
        temple
      end
    end
  end
end
