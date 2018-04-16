module Temple
  module Filters
    # Flattens nested multi expressions
    #
    # @api public
    class MultiFlattener < Filter
      def on_multi(*exps)
        # If the multi contains a single element, just return the element
        return compile(exps.first) if exps.size == 1
        result = [:multi]

        exps.each do |exp|
          exp = compile(exp)
          if exp.first == :multi
            result.concat(exp[1..-1])
          else
            result << exp
          end
        end

        result
      end
    end
  end
end
