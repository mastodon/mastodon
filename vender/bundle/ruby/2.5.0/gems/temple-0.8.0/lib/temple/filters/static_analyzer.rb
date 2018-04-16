module Temple
  module Filters
    # Convert [:dynamic, code] to [:static, text] if code is static Ruby expression.
    class StaticAnalyzer < Filter
      def call(exp)
        # Optimize only when Ripper is available.
        if ::Temple::StaticAnalyzer.available?
          super
        else
          exp
        end
      end

      def on_dynamic(code)
        if ::Temple::StaticAnalyzer.static?(code)
          exp = [:static, eval(code).to_s]

          newlines = code.count("\n")
          if newlines == 0
            exp
          else
            [:multi, exp, *newlines.times.map { [:newline] }]
          end
        else
          [:dynamic, code]
        end
      end
    end
  end
end
