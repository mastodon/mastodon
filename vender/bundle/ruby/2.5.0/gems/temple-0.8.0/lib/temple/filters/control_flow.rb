module Temple
  module Filters
    # Control flow filter which processes [:if, condition, yes-exp, no-exp]
    # and [:block, code, content] expressions.
    # This is useful for ruby code generation with lots of conditionals.
    #
    # @api public
    class ControlFlow < Filter
      def on_if(condition, yes, no = nil)
        result = [:multi, [:code, "if #{condition}"], compile(yes)]
        while no && no.first == :if
          result << [:code, "elsif #{no[1]}"] << compile(no[2])
          no = no[3]
        end
        result << [:code, 'else'] << compile(no) if no
        result << [:code, 'end']
        result
      end

      def on_case(arg, *cases)
        result = [:multi, [:code, arg ? "case (#{arg})" : 'case']]
        cases.map do |c|
          condition, exp = c
          result << [:code, condition == :else ? 'else' : "when #{condition}"] << compile(exp)
        end
        result << [:code, 'end']
        result
      end

      def on_cond(*cases)
        on_case(nil, *cases)
      end

      def on_block(code, exp)
        [:multi,
         [:code, code],
         compile(exp),
         [:code, 'end']]
      end
    end
  end
end
