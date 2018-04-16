# frozen_string_literal: true
module Hamlit
  class Filters
    class Erb < TiltBase
      def compile(node)
        compile_with_tilt(node, 'erb')
      end
    end
  end
end
