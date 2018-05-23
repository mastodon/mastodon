# frozen_string_literal: true
module Hamlit
  class Filters
    class TextBase < Base
      def compile_text!(temple, node, prefix)
        text = node.value[:text].rstrip.gsub(/^/, prefix)
        if ::Hamlit::HamlUtil.contains_interpolation?(node.value[:text])
          # original: Haml::Filters#compile
          text = ::Hamlit::HamlUtil.slow_unescape_interpolation(text).gsub(/(\\+)n/) do |s|
            escapes = $1.size
            next s if escapes % 2 == 0
            "#{'\\' * (escapes - 1)}\n"
          end
          text.prepend("\n")
          temple << [:dynamic, text]
        else
          node.value[:text].split("\n").size.times do
            temple << [:newline]
          end
          temple << [:static, text]
        end
      end
    end
  end
end
