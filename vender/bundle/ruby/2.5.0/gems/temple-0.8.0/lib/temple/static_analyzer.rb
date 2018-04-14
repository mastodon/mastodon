begin
  require 'ripper'
rescue LoadError
end

module Temple
  module StaticAnalyzer
    STATIC_TOKENS = [
      :on_tstring_beg, :on_tstring_end, :on_tstring_content,
      :on_embexpr_beg, :on_embexpr_end,
      :on_lbracket, :on_rbracket,
      :on_qwords_beg, :on_words_sep, :on_qwords_sep,
      :on_lparen, :on_rparen,
      :on_lbrace, :on_rbrace, :on_label,
      :on_int, :on_float, :on_imaginary,
      :on_comma, :on_sp, :on_ignored_nl,
    ].freeze

    DYNAMIC_TOKENS = [
      :on_ident, :on_period,
    ].freeze

    STATIC_KEYWORDS = [
      'true', 'false', 'nil',
    ].freeze

    STATIC_OPERATORS = [
      '=>',
    ].freeze

    class << self
      def available?
        defined?(Ripper)
      end

      def static?(code)
        return false if code.nil? || code.strip.empty?
        return false if syntax_error?(code)

        Ripper.lex(code).each do |_, token, str|
          case token
          when *STATIC_TOKENS
            # noop
          when :on_kw
            return false unless STATIC_KEYWORDS.include?(str)
          when :on_op
            return false unless STATIC_OPERATORS.include?(str)
          when *DYNAMIC_TOKENS
            return false
          else
            return false
          end
        end
        true
      end

      def syntax_error?(code)
        SyntaxChecker.new(code).parse
        false
      rescue SyntaxChecker::ParseError
        true
      end
    end

    if defined?(Ripper)
      class SyntaxChecker < Ripper
        class ParseError < StandardError; end

        private

        def on_parse_error(*)
          raise ParseError
        end
      end
    end
  end
end
