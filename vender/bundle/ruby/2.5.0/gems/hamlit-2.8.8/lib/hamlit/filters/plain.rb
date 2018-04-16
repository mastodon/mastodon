# frozen_string_literal: true
require 'hamlit/string_splitter'

module Hamlit
  class Filters
    class Plain < Base
      def compile(node)
        text = node.value[:text]
        text = text.rstrip unless ::Hamlit::HamlUtil.contains_interpolation?(text) # for compatibility
        [:multi, *compile_plain(text)]
      end

      private

      def compile_plain(text)
        string_literal = ::Hamlit::HamlUtil.unescape_interpolation(text)
        StringSplitter.compile(string_literal).map do |temple|
          type, str = temple
          case type
          when :dynamic
            [:escape, false, [:dynamic, str]]
          else
            temple
          end
        end
      end
    end
  end
end
