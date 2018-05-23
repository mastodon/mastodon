begin
  require 'ripper'
rescue LoadError
end

module Temple
  module Filters
    # Compile [:dynamic, "foo#{bar}"] to [:multi, [:static, 'foo'], [:dynamic, 'bar']]
    class StringSplitter < Filter
      if defined?(Ripper) && RUBY_VERSION >= "2.0.0"
        class << self
          # `code` param must be valid string literal
          def compile(code)
            [].tap do |exps|
              tokens = Ripper.lex(code.strip)
              tokens.pop while tokens.last && [:on_comment, :on_sp].include?(tokens.last[1])

              if tokens.size < 2
                raise(FilterError, "Expected token size >= 2 but got: #{tokens.size}")
              end
              compile_tokens!(exps, tokens)
            end
          end

          private

          def strip_quotes!(tokens)
            _, type, beg_str = tokens.shift
            if type != :on_tstring_beg
              raise(FilterError, "Expected :on_tstring_beg but got: #{type}")
            end

            _, type, end_str = tokens.pop
            if type != :on_tstring_end
              raise(FilterError, "Expected :on_tstring_end but got: #{type}")
            end

            [beg_str, end_str]
          end

          def compile_tokens!(exps, tokens)
            beg_str, end_str = strip_quotes!(tokens)

            until tokens.empty?
              _, type, str = tokens.shift

              case type
              when :on_tstring_content
                exps << [:static, eval("#{beg_str}#{str}#{end_str}").to_s]
              when :on_embexpr_beg
                embedded = shift_balanced_embexpr(tokens)
                exps << [:dynamic, embedded] unless embedded.empty?
              end
            end
          end

          def shift_balanced_embexpr(tokens)
            String.new.tap do |embedded|
              embexpr_open = 1

              until tokens.empty?
                _, type, str = tokens.shift
                case type
                when :on_embexpr_beg
                  embexpr_open += 1
                when :on_embexpr_end
                  embexpr_open -= 1
                  break if embexpr_open == 0
                end

                embedded << str
              end
            end
          end
        end

        def on_dynamic(code)
          return [:dynamic, code] unless string_literal?(code)
          return [:dynamic, code] if code.include?("\n")

          temple = [:multi]
          StringSplitter.compile(code).each do |type, content|
            case type
            when :static
              temple << [:static, content]
            when :dynamic
              temple << on_dynamic(content)
            end
          end
          temple
        end

        private

        def string_literal?(code)
          return false if SyntaxChecker.syntax_error?(code)

          type, instructions = Ripper.sexp(code)
          return false if type != :program
          return false if instructions.size > 1

          type, _ = instructions.first
          type == :string_literal
        end

        class SyntaxChecker < Ripper
          class ParseError < StandardError; end

          def self.syntax_error?(code)
            self.new(code).parse
            false
          rescue ParseError
            true
          end

          private

          def on_parse_error(*)
            raise ParseError
          end
        end
      else
        # Do nothing if ripper is unavailable
        def call(ast)
          ast
        end
      end
    end
  end
end
