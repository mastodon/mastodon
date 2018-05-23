# frozen_string_literal: true
module Hamlit
  class Filters
    class Cdata < TextBase
      def compile(node)
        compile_cdata(node)
      end

      private

      def compile_cdata(node)
        temple = [:multi]
        temple << [:static, "<![CDATA[\n"]
        compile_text!(temple, node, '    ')
        temple << [:static, "\n]]>"]
        temple
      end
    end
  end
end
