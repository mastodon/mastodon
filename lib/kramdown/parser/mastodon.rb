# frozen_string_literal: true

require 'kramdown/parser'

module Kramdown
  module Parser
    class Mastodon < GFM
      def initialize(source, options)
        super

        # @block_parsers = %i(blank_line paragraph)
        # @span_parsers  = %i(no_intra_emphasis codespan immediate_line_break escaped_chars)
      end

      def parse_immediate_line_break
        @tree.children << Element.new(:br, nil, nil, location: @src.current_line_number)
        @src.pos += @src.matched_size
      end

      define_parser(:immediate_line_break, /\n/, '\n')

      def parse_no_intra_emphasis
        start_line_number = @src.current_line_number
        saved_pos         = @src.save_pos

        result  = @src.scan(EMPHASIS_START)
        element = (result.length == 2 ? :strong : :em)
        type    = result[0..0]

        if (@src.pre_match =~ /[[:alpha:]-]\z/) || @src.check(/\s/) || @tree.type == element || @stack.any? { |el, _| el.type == element }
          add_text(result)
          return
        end

        sub_parse = lambda do |delim, elem|
          el      = Element.new(elem, nil, nil, location: start_line_number)
          stop_re = /#{Regexp.escape(delim)}/

          found = parse_spans(el, stop_re) do
            (@src.pre_match[-1, 1] !~ /\s/) &&
              (elem != :em || !@src.match?(/#{Regexp.escape(delim * 2)}(?!#{Regexp.escape(delim)})/)) &&
              (type != '_' || !@src.match?(/#{Regexp.escape(delim)}[[:alnum:]]/)) && !el.children.empty?
          end

          [found, el, stop_re]
        end

        found, el, stop_re = sub_parse.call(result, element)

        if !found && element == :strong && @tree.type != :em
          @src.revert_pos(saved_pos)
          @src.pos += 1
          found, el, stop_re = sub_parse.call(type, :em)
        end

        if found
          @src.scan(stop_re)
          @tree.children << el
        else
          @src.revert_pos(saved_pos)
          @src.pos += result.length
          add_text(result)
        end
      end

      define_parser(:no_intra_emphasis, EMPHASIS_START, '\*|_')
    end
  end
end