# encoding: utf-8
# frozen_string_literal: true

require_relative 'question'
require_relative 'symbols'

module TTY
  class Prompt
    # A prompt responsible for multi line user input
    #
    # @api private
    class Multiline < Question
      HELP = '(Press CTRL-D or CTRL-Z to finish)'.freeze

      def initialize(prompt, options = {})
        super
        @help         = options[:help] || self.class::HELP
        @first_render = true
        @lines_count  = 0

        @prompt.subscribe(self)
      end

      # Provide help information
      #
      # @return [String]
      #
      # @api public
      def help(value = (not_set = true))
        return @help if not_set
        @help = value
      end

      def read_input
        @prompt.read_multiline
      end

      def keyreturn(*)
        @lines_count += 1
      end
      alias keyenter keyreturn

      def render_question
        header = ["#{@prefix}#{message} "]
        if !echo?
          header
        elsif @done
          header << @prompt.decorate("#{@input}", @active_color)
        elsif @first_render
          header << @prompt.decorate(help, @help_color)
          @first_render = false
        end
        header << "\n"
        header.join
      end

      def process_input(question)
        @prompt.print(question)
        @lines = read_input
        @input = "#{@lines.first.strip} ..." unless @lines.first.to_s.empty?
        if Utils.blank?(@input)
          @input = default? ? default : nil
        end
        @evaluator.(@lines)
      end

      def refresh(lines, lines_to_clear)
        size = @lines_count + lines_to_clear + 1
        @prompt.clear_lines(size)
      end
    end # Multiline
  end # Prompt
end # TTY
