module Temple
  module Filters
    # @api public
    class CodeMerger < Filter
      def on_multi(*exps)
        result = [:multi]
        code = nil

        exps.each do |exp|
          if exp.first == :code
            if code
              code << '; ' unless code =~ /\n\Z/
              code << exp.last
            else
              code = exp.last.dup
              result << [:code, code]
            end
          elsif code && exp.first == :newline
            code << "\n"
          else
            result << compile(exp)
            code = nil
          end
        end

        result.size == 2 ? result[1] : result
      end
    end
  end
end
