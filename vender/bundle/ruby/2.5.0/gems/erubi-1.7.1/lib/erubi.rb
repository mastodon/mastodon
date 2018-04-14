# frozen_string_literal: true

module Erubi
  VERSION = '1.7.1'
  RANGE_ALL = 0..-1

  if RUBY_VERSION >= '1.9'
    RANGE_FIRST = 0
    RANGE_LAST = -1
    TEXT_END = RUBY_VERSION >= '2.1' ? "'.freeze;" : "';"
  else
    # :nocov:
    RANGE_FIRST = 0..0
    RANGE_LAST = -1..-1
    TEXT_END = "';"
  end

  begin
    require 'cgi/escape'
    unless CGI.respond_to?(:escapeHTML) # work around for JRuby 9.1
      CGI = Object.new
      CGI.extend(defined?(::CGI::Escape) ? ::CGI::Escape : ::CGI::Util)
    end
    def self.h(value)
      CGI.escapeHTML(value.to_s)
    end
  rescue LoadError
    ESCAPE_TABLE = {'&' => '&amp;'.freeze, '<' => '&lt;'.freeze, '>' => '&gt;'.freeze, '"' => '&quot;'.freeze, "'" => '&#39;'.freeze}.freeze
    if RUBY_VERSION >= '1.9'
      # Escape the following characters with their HTML/XML
      # equivalents.
      def self.h(value)
        value.to_s.gsub(/[&<>"']/, ESCAPE_TABLE)
      end
    else
      def self.h(value)
        value.to_s.gsub(/[&<>"']/){|s| ESCAPE_TABLE[s]}
      end
    end
  end

  class Engine
    # The frozen ruby source code generated from the template, which can be evaled.
    attr_reader :src

    # The filename of the template, if one was given.
    attr_reader :filename

    # The variable name used for the buffer variable.
    attr_reader :bufvar

    # Initialize a new Erubi::Engine.  Options:
    # :bufval :: The value to use for the buffer variable, as a string.
    # :bufvar :: The variable name to use for the buffer variable, as a string.
    # :ensure :: Wrap the template in a begin/ensure block restoring the previous value of bufvar.
    # :escapefunc :: The function to use for escaping, as a string (default: ::Erubi.h).
    # :escape :: Whether to make <%= escape by default, and <%== not escape by default.
    # :escape_html :: Same as :escape, with lower priority.
    # :filename :: The filename for the template.
    # :freeze :: Whether to enable frozen string literals in the resulting source code.
    # :outvar :: Same as bufvar, with lower priority.
    # :postamble :: The postamble for the template, by default returns the resulting source code.
    # :preamble :: The preamble for the template, by default initializes up the buffer variable.
    # :regexp :: The regexp to use for scanning.
    # :src :: The initial value to use for the source code
    # :trim :: Whether to trim leading and trailing whitespace, true by default.
    def initialize(input, properties={})
      @escape = escape = properties.fetch(:escape){properties.fetch(:escape_html, false)}
      trim       = properties[:trim] != false
      @filename  = properties[:filename]
      @bufvar = bufvar = properties[:bufvar] || properties[:outvar] || "_buf"
      bufval = properties[:bufval] || 'String.new'
      regexp = properties[:regexp] || /<%(={1,2}|-|\#|%)?(.*?)([-=])?%>([ \t]*\r?\n)?/m
      preamble   = properties[:preamble] || "#{bufvar} = #{bufval};"
      postamble  = properties[:postamble] || "#{bufvar}.to_s\n"

      @src = src = properties[:src] || String.new
      src << "# frozen_string_literal: true\n" if properties[:freeze]
      src << "begin; __original_outvar = #{bufvar} if defined?(#{bufvar}); " if properties[:ensure]

      unless @escapefunc = properties[:escapefunc]
        if escape
          @escapefunc = '__erubi.h'
          src << "__erubi = ::Erubi;"
        else
          @escapefunc = '::Erubi.h'
        end
      end

      src << preamble

      pos = 0
      is_bol = true
      input.scan(regexp) do |indicator, code, tailch, rspace|
        match = Regexp.last_match
        len  = match.begin(0) - pos
        text = input[pos, len]
        pos  = match.end(0)
        ch   = indicator ? indicator[RANGE_FIRST] : nil

        lspace = nil

        unless ch == '='
          if text.empty?
            lspace = "" if is_bol
          elsif text[RANGE_LAST] == "\n"
            lspace = ""
          else
            rindex = text.rindex("\n")
            if rindex
              range = rindex+1..-1
              s = text[range]
              if s =~ /\A[ \t]*\z/
                lspace = s
                text[range] = ''
              end
            else
              if is_bol && text =~ /\A[ \t]*\z/
                lspace = text.dup
                text[RANGE_ALL] = ''
              end
            end
          end
        end

        is_bol = rspace
        add_text(text) if text && !text.empty?
        case ch
        when '='
          rspace = nil if tailch && !tailch.empty?
          add_text(lspace) if lspace
          add_expression(indicator, code)
          add_text(rspace) if rspace
        when '#'
          n = code.count("\n") + (rspace ? 1 : 0)
          if trim && lspace && rspace
            add_code("\n" * n)
          else
            add_text(lspace) if lspace
            add_code("\n" * n)
            add_text(rspace) if rspace
          end
        when '%'
          add_text("#{lspace}#{prefix||='<%'}#{code}#{tailch}#{postfix||='%>'}#{rspace}")
        when nil, '-'
          if trim && lspace && rspace
            add_code("#{lspace}#{code}#{rspace}")
          else
            add_text(lspace) if lspace
            add_code(code)
            add_text(rspace) if rspace
          end
        else
          handle(indicator, code, tailch, rspace, lspace)
        end
      end
      rest = pos == 0 ? input : input[pos..-1]
      add_text(rest)

      src << "\n" unless src[RANGE_LAST] == "\n"
      add_postamble(postamble)
      src << "; ensure\n  #{bufvar} = __original_outvar\nend\n" if properties[:ensure]
      src.freeze
      freeze
    end

    private

    # Add raw text to the template
    def add_text(text)
      @src << " #{@bufvar} << '" << text.gsub(/['\\]/, '\\\\\&') << TEXT_END unless text.empty?
    end

    # Add ruby code to the template
    def add_code(code)
      @src << code
      @src << ';' unless code[RANGE_LAST] == "\n"
    end

    # Add the given ruby expression result to the template,
    # escaping it based on the indicator given and escape flag.
    def add_expression(indicator, code)
      if ((indicator == '=') ^ @escape)
        add_expression_result(code)
      else
        add_expression_result_escaped(code)
      end
    end

    # Add the result of Ruby expression to the template
    def add_expression_result(code)
      @src << " #{@bufvar} << (" << code << ').to_s;'
    end

    # Add the escaped result of Ruby expression to the template
    def add_expression_result_escaped(code)
      @src << " #{@bufvar} << #{@escapefunc}((" << code << '));'
    end

    # Add the given postamble to the src.  Can be overridden in subclasses
    # to make additional changes to src that depend on the current state.
    def add_postamble(postamble)
      src << postamble
    end

    # Raise an exception, as the base engine class does not support handling other indicators.
    def handle(indicator, code, tailch, rspace, lspace)
      raise ArgumentError, "Invalid indicator: #{indicator}"
    end
  end
end
