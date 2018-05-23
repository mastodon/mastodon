module Temple
  module Generators
    # Implements an ERB generator.
    #
    # @api public
    class ERB < Generator
      def call(exp)
        compile(exp)
      end

      def on_multi(*exp)
        exp.map {|e| compile(e) }.join('')
      end

      def on_capture(name, exp)
        on_code(super)
      end

      def on_static(text)
        text
      end

      def on_dynamic(code)
        "<%= #{code} %>"
      end

      def on_code(code)
        "<% #{code} %>"
      end
    end
  end
end
