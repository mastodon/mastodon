# frozen_string_literal: true
module Hamlit
  class Filters
    class Coffee < TiltBase
      def compile(node)
        require 'tilt/coffee' if explicit_require?('coffee')
        temple = [:multi]
        temple << [:static, "<script>\n"]
        temple << compile_with_tilt(node, 'coffee', indent_width: 2)
        temple << [:static, "</script>"]
        temple
      end
    end

    CoffeeScript = Coffee
  end
end
