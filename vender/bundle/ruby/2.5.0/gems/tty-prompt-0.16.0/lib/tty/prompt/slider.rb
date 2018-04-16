# encoding: utf-8
# frozen_string_literal: true

require_relative 'symbols'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering numeric input from range
    #
    # @api public
    class Slider
      include Symbols

      HELP = '(Use arrow keys, press Enter to select)'.freeze

      FORMAT = ':slider %d'.freeze

      # Initailize a Slider
      #
      # @param [Prompt] prompt
      #   the prompt
      # @param [Hash] options
      #   the options to configure this slider
      # @option options [Integer] :min The minimum value
      # @option options [Integer] :max The maximum value
      # @option options [Integer] :step The step value
      # @option options [String] :format The display format
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt       = prompt
        @prefix       = options.fetch(:prefix) { @prompt.prefix }
        @min          = options.fetch(:min) { 0 }
        @max          = options.fetch(:max) { 10 }
        @step         = options.fetch(:step) { 1 }
        @default      = options[:default]
        @active_color = options.fetch(:active_color) { @prompt.active_color }
        @help_color   = options.fetch(:help_color) { @prompt.help_color }
        @format       = options.fetch(:format) { FORMAT }
        @first_render = true
        @done         = false

        @prompt.subscribe(self)
      end

      # Setup initial active position
      #
      # @return [Integer]
      #
      # @api private
      def initial
        if @default.nil?
          range.size / 2
        else
          range.index(@default)
        end
      end

      # Range of numbers to render
      #
      # @return [Array[Integer]]
      #
      # @apip private
      def range
        (@min..@max).step(@step).to_a
      end

      # @api public
      def default(value)
        @default = value
      end

      # @api public
      def min(value)
        @min = value
      end

      # @api public
      def max(value)
        @max = value
      end

      # @api public
      def step(value)
        @step = value
      end

      def format(value)
        @format = value
      end

      # Call the slider by passing question
      #
      # @param [String] question
      #   the question to ask
      #
      # @apu public
      def call(question, &block)
        @question = question
        block.call(self) if block
        @active = initial
        render
      end

      def keyleft(*)
        @active -= 1 if @active > 0
      end
      alias keydown keyleft

      def keyright(*)
        @active += 1 if (@active + 1) < range.size
      end
      alias keyup keyright

      def keyreturn(*)
        @done = true
      end
      alias keyspace keyreturn
      alias keyenter keyreturn

      private

      # Render an interactive range slider.
      #
      # @api private
      def render
        @prompt.print(@prompt.hide)
        until @done
          question = render_question
          @prompt.print(question)
          @prompt.read_keypress
          refresh(question.lines.count)
        end
        @prompt.print(render_question)
        answer
      ensure
        @prompt.print(@prompt.show)
      end

      # Clear screen
      #
      # @param [Integer] lines
      #   the lines to clear
      #
      # @api private
      def refresh(lines)
        @prompt.print(@prompt.clear_lines(lines))
      end

      # @return [Integer]
      #
      # @api private
      def answer
        range[@active]
      end

      # Render question with the slider
      #
      # @return [String]
      #
      # @api private
      def render_question
        header = ["#{@prefix}#{@question} "]
        if @done
          header << @prompt.decorate(answer.to_s, @active_color)
          header << "\n"
        else
          header << render_slider
        end
        if @first_render
          header << "\n" + @prompt.decorate(HELP, @help_color)
          @first_render = false
        end
        header.join
      end

      # Render slider representation
      #
      # @return [String]
      #
      # @api private
      def render_slider
        slider = (symbols[:line] * @active) +
                 @prompt.decorate(symbols[:handle], @active_color) +
                 (symbols[:line] * (range.size - @active - 1))
        value = " #{range[@active]}"
        @format.gsub(':slider', slider) % [value]
      end
    end # Slider
  end # Prompt
end # TTY
