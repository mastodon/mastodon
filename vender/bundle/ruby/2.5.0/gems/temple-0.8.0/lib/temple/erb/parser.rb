module Temple
  module ERB
    # Example ERB parser
    #
    # @api public
    class Parser < Temple::Parser
      ERB_PATTERN = /(\n|<%%|%%>)|<%(==?|\#)?(.*?)?-?%>/m

      def call(input)
        result = [:multi]
        pos = 0
        input.scan(ERB_PATTERN) do |token, indicator, code|
          text = input[pos...$~.begin(0)]
          pos  = $~.end(0)
          if token
            case token
            when "\n"
              result << [:static, "#{text}\n"] << [:newline]
            when '<%%', '%%>'
              result << [:static, text] unless text.empty?
              token.slice!(1)
              result << [:static, token]
            end
          else
            result << [:static, text] unless text.empty?
            case indicator
            when '#'
              result << [:code, "\n" * code.count("\n")]
            when /=/
              result << [:escape, indicator.size <= 1, [:dynamic, code]]
            else
              result << [:code, code]
            end
          end
        end
        result << [:static, input[pos..-1]]
      end
    end
  end
end
