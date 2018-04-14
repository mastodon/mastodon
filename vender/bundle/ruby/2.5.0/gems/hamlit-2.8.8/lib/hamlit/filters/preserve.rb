# frozen_string_literal: true
module Hamlit
  class Filters
    class Preserve < Base
      def compile(node)
        text = node.value[:text].rstrip + "\n"
        text = text.gsub("\n", '&#x000A;')
        compile_text(text)
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
