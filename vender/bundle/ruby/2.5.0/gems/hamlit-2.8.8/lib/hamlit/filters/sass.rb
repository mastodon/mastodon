# frozen_string_literal: true
module Hamlit
  class Filters
    class Sass < TiltBase
      def compile(node)
        require 'tilt/sass' if explicit_require?('sass')
        temple = [:multi]
        temple << [:static, "<style>\n"]
        temple << compile_with_tilt(node, 'sass', indent_width: 2)
        temple << [:static, "</style>"]
        temple
      end
    end
  end
end
