# frozen_string_literal: true
module Hamlit
  class Filters
    class Escaped < Base
      def compile(node)
        text = node.value[:text].rstrip
        temple = compile_text(text)
        [:escape, true, temple]
      end

      private

      def compile_text(text)
        if ::Hamlit::HamlUtil.contains_interpolation?(text)
          [:dynamic, ::Hamlit::HamlUtil.slow_unescape_interpolation(text)]
        else
          [:static, text]
        end
      end
    end
  end
end
