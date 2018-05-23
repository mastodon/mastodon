module MethodSource

  module CodeHelpers
    # Retrieve the first expression starting on the given line of the given file.
    #
    # This is useful to get module or method source code.
    #
    # @param [Array<String>, File, String] file  The file to parse, either as a File or as
    # @param [Integer]  line_number  The line number at which to look.
    #                             NOTE: The first line in a file is
    #                           line 1!
    # @param [Hash] options The optional configuration parameters.
    # @option options [Boolean] :strict  If set to true, then only completely
    #   valid expressions are returned. Otherwise heuristics are used to extract
    #   expressions that may have been valid inside an eval.
    # @option options [Integer] :consume  A number of lines to automatically
    #   consume (add to the expression buffer) without checking for validity.
    # @return [String]  The first complete expression
    # @raise [SyntaxError]  If the first complete expression can't be identified
    def expression_at(file, line_number, options={})
      options = {
        :strict  => false,
        :consume => 0
      }.merge!(options)

      lines = file.is_a?(Array) ? file : file.each_line.to_a

      relevant_lines = lines[(line_number - 1)..-1] || []

      extract_first_expression(relevant_lines, options[:consume])
    rescue SyntaxError => e
      raise if options[:strict]

      begin
        extract_first_expression(relevant_lines) do |code|
          code.gsub(/\#\{.*?\}/, "temp")
        end
      rescue SyntaxError
        raise e
      end
    end

    # Retrieve the comment describing the expression on the given line of the given file.
    #
    # This is useful to get module or method documentation.
    #
    # @param [Array<String>, File, String] file  The file to parse, either as a File or as
    #                                            a String or an Array of lines.
    # @param [Integer]  line_number  The line number at which to look.
    #                             NOTE: The first line in a file is line 1!
    # @return [String]  The comment
    def comment_describing(file, line_number)
      lines = file.is_a?(Array) ? file : file.each_line.to_a

      extract_last_comment(lines[0..(line_number - 2)])
    end

    # Determine if a string of code is a complete Ruby expression.
    # @param [String] code The code to validate.
    # @return [Boolean] Whether or not the code is a complete Ruby expression.
    # @raise [SyntaxError] Any SyntaxError that does not represent incompleteness.
    # @example
    #   complete_expression?("class Hello") #=> false
    #   complete_expression?("class Hello; end") #=> true
    #   complete_expression?("class 123") #=> SyntaxError: unexpected tINTEGER
    def complete_expression?(str)
      old_verbose = $VERBOSE
      $VERBOSE = nil

      catch(:valid) do
        eval("BEGIN{throw :valid}\n#{str}")
      end

      # Assert that a line which ends with a , or \ is incomplete.
      str !~ /[,\\]\s*\z/
    rescue IncompleteExpression
      false
    ensure
      $VERBOSE = old_verbose
    end

    private

    # Get the first expression from the input.
    #
    # @param [Array<String>]  lines
    # @param [Integer] consume A number of lines to automatically
    #   consume (add to the expression buffer) without checking for validity.
    # @yield a clean-up function to run before checking for complete_expression
    # @return [String]  a valid ruby expression
    # @raise [SyntaxError]
    def extract_first_expression(lines, consume=0, &block)
      code = consume.zero? ? "" : lines.slice!(0..(consume - 1)).join

      lines.each do |v|
        code << v
        return code if complete_expression?(block ? block.call(code) : code)
      end
      raise SyntaxError, "unexpected $end"
    end

    # Get the last comment from the input.
    #
    # @param [Array<String>]  lines
    # @return [String]
    def extract_last_comment(lines)
      buffer = ""

      lines.each do |line|
        # Add any line that is a valid ruby comment,
        # but clear as soon as we hit a non comment line.
        if (line =~ /^\s*#/) || (line =~ /^\s*$/)
          buffer << line.lstrip
        else
          buffer.replace("")
        end
      end

      buffer
    end

    # An exception matcher that matches only subsets of SyntaxErrors that can be
    # fixed by adding more input to the buffer.
    module IncompleteExpression
      GENERIC_REGEXPS = [
        /unexpected (\$end|end-of-file|end-of-input|END_OF_FILE)/, # mri, jruby, ruby-2.0, ironruby
        /embedded document meets end of file/, # =begin
        /unterminated (quoted string|string|regexp) meets end of file/, # "quoted string" is ironruby
        /can't find string ".*" anywhere before EOF/, # rbx and jruby
        /missing 'end' for/, /expecting kWHEN/ # rbx
      ]

      RBX_ONLY_REGEXPS = [
        /expecting '[})\]]'(?:$|:)/, /expecting keyword_end/
      ]

      def self.===(ex)
        return false unless SyntaxError === ex
        case ex.message
        when *GENERIC_REGEXPS
          true
        when *RBX_ONLY_REGEXPS
          rbx?
        else
          false
        end
      end

      def self.rbx?
        RbConfig::CONFIG['ruby_install_name'] == 'rbx'
      end
    end
  end
end
