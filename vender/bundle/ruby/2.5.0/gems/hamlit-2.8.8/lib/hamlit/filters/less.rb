# frozen_string_literal: true
# LESS support is deprecated since it requires therubyracer.gem,
# which is hard to maintain.
#
# It's not supported in Sprockets 3.0+ too.
# https://github.com/sstephenson/sprockets/pull/547
module Hamlit
  class Filters
    class Less < TiltBase
      def compile(node)
        require 'tilt/less' if explicit_require?('less')
        temple = [:multi]
        temple << [:static, "<style>\n"]
        temple << compile_with_tilt(node, 'less', indent_width: 2)
        temple << [:static, '</style>']
        temple
      end
    end
  end
end
