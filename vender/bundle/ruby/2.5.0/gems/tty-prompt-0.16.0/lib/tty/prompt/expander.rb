# encoding: utf-8
# frozen_string_literal: true

require_relative 'choices'

module TTY
  class Prompt
    # A class responsible for rendering expanding options
    # Used by {Prompt} to display key options question.
    #
    # @api private
    class Expander
      HELP_CHOICE = {
        key: 'h',
        name: 'print help',
        value: :help
      }.freeze

      # Create instance of Expander
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt       = prompt
        @prefix       = options.fetch(:prefix) { @prompt.prefix }
        @default      = options.fetch(:default) { 1 }
        @active_color = options.fetch(:active_color) { @prompt.active_color }
        @help_color   = options.fetch(:help_color) { @prompt.help_color }
        @choices      = Choices.new
        @selected     = nil
        @done         = false
        @status       = :collapsed
        @hint         = nil
        @default_key  = false

        @prompt.subscribe(self)
      end

      def expanded?
        @status == :expanded
      end

      def collapsed?
        @status == :collapsed
      end

      def expand
        @status = :expanded
      end

      # Respond to submit event
      #
      # @api public
      def keyenter(_)
        if @input.nil? || @input.empty?
          @input = @choices[@default - 1].key
          @default_key = true
        end

        selected = select_choice(@input)

        if selected && selected.key.to_s == 'h'
          expand
          @selected = nil
          @input = ''
        elsif selected
          @done = true
          @selected = selected
        else
          @input = ''
        end
      end
      alias keyreturn keyenter

      # Respond to key press event
      #
      # @api public
      def keypress(event)
        if [:backspace, :delete].include?(event.key.name)
          @input.chop! unless @input.empty?
        elsif event.value =~ /^[^\e\n\r]/
          @input += event.value
        end
        @selected = select_choice(@input)
        if @selected && !@default_key && collapsed?
          @hint = @selected.name
        end
      end

      # Select choice by given key
      #
      # @return [Choice]
      #
      # @api private
      def select_choice(key)
        @choices.find_by(:key, key)
      end

      # Set default value.
      #
      # @api public
      def default(value = (not_set = true))
        return @default if not_set
        @default = value
      end

      # Add a single choice
      #
      # @api public
      def choice(value, &block)
        if block
          @choices << value.update(value: block)
        else
          @choices << value
        end
      end

      # Add multiple choices
      #
      # @param [Array[Object]] values
      #   the values to add as choices
      #
      # @api public
      def choices(values)
        values.each { |val| choice(val) }
      end

      # Execute this prompt
      #
      # @api public
      def call(message, possibilities, &block)
        choices(possibilities)
        @message = message
        block.call(self) if block
        setup_defaults
        choice(HELP_CHOICE)
        render
      end

      private

      # Create possible keys with current choice highlighted
      #
      # @return [String]
      #
      # @api private
      def possible_keys
        keys = @choices.pluck(:key)
        default_key = keys[@default - 1]
        if @selected
          index = keys.index(@selected.key)
          keys[index] = @prompt.decorate(keys[index], @active_color)
        elsif @input.to_s.empty? && default_key
          keys[@default - 1] = @prompt.decorate(default_key, @active_color)
        end
        keys.join(',')
      end

      # @api private
      def render
        @input = ''
        until @done
          question = render_question
          @prompt.print(question)
          read_input
          @prompt.print(refresh(question.lines.count))
        end
        @prompt.print(render_question)
        answer
      end

      # @api private
      def answer
        @selected.value
      end

      # Render message with options
      #
      # @return [String]
      #
      # @api private
      def render_header
        header = ["#{@prefix}#{@message} "]
        if @done
          selected_item = @selected.name.to_s
          header << @prompt.decorate(selected_item, @active_color)
        elsif collapsed?
          header << %[(enter "h" for help) ]
          header << "[#{possible_keys}] "
          header << @input
        end
        header.join
      end

      # Show hint for selected option key
      #
      # return [String]
      #
      # @api private
      def render_hint
        "\n" + @prompt.decorate('>> ', @active_color) +
          @hint +
          @prompt.cursor.prev_line +
          @prompt.cursor.forward(@prompt.strip(render_header).size)
      end

      # Render question with menu
      #
      # @return [String]
      #
      # @api private
      def render_question
        header = render_header
        header << render_hint if @hint
        header << "\n" if @done

        if !@done && expanded?
          header << render_menu
          header << render_footer
        end
        header
      end

      def render_footer
        "  Choice [#{@choices[@default - 1].key}]: #{@input}"
      end

      def read_input
        @prompt.read_keypress
      end

      # Refresh the current input
      #
      # @param [Integer] lines
      #
      # @return [String]
      #
      # @api private
      def refresh(lines)
        if @hint && (!@selected || @done)
          @hint = nil
          @prompt.clear_lines(lines, :down) +
            @prompt.cursor.prev_line
        elsif expanded?
          @prompt.clear_lines(lines)
        else
          @prompt.clear_line
        end
      end

      # Render help menu
      #
      # @api private
      def render_menu
        output = ["\n"]
        @choices.each do |choice|
          chosen = %(#{choice.key} - #{choice.name})
          if @selected && @selected.key == choice.key
            chosen = @prompt.decorate(chosen, @active_color)
          end
          output << '  ' + chosen + "\n"
        end
        output.join
      end

      def setup_defaults
        validate_choices
      end

      def validate_choices
        errors = []
        keys = []
        @choices.each do |choice|
          if choice.key.nil?
            errors << "Choice #{choice.name} is missing a :key attribute"
            next
          end
          if choice.key.length != 1
            errors << "Choice key `#{choice.key}` is more than one character long."
          end
          if choice.key.to_s == 'h'
            errors << "Choice key `#{choice.key}` is reserved for help menu."
          end
          if keys.include?(choice.key)
            errors << "Choice key `#{choice.key}` is a duplicate."
          end
          keys << choice.key if choice.key
        end
        errors.each { |err| raise ConfigurationError, err }
      end
    end # Expander
  end # Prompt
end # TTY
