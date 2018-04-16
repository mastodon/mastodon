# frozen_string_literal: true
module Hamlit
  class Filters
    class Scss < TiltBase
      def compile(node)
        require 'tilt/sass' if explicit_require?('scss')
        temple = [:multi]
        temple << [:static, "<style>\n"]
        temple << compile_with_tilt(node, 'scss', indent_width: 2)
        temple << [:static, "</style>"]
        temple
      end
    end
  end
end
