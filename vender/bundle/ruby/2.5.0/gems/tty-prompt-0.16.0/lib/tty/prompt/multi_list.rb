# encoding: utf-8
# frozen_string_literal: true

require_relative 'list'

module TTY
  class Prompt
    # A class responsible for rendering multi select list menu.
    # Used by {Prompt} to display interactive choice menu.
    #
    # @api private
    class MultiList < List
      HELP = '(Use arrow%s keys, press Space to select and Enter to finish%s)'.freeze

      # Create instance of TTY::Prompt::MultiList menu.
      #
      # @param [Prompt] :prompt
      # @param [Hash] options
      #
      # @api public
      def initialize(prompt, options)
        super
        @selected = []
        @help    = options[:help]
        @default = Array(options[:default])
        @echo = options.fetch(:echo, true)
      end

      # Callback fired when space key is pressed
      #
      # @api private
      def keyspace(*)
        active_choice = choices[@active - 1]
        if @selected.include?(active_choice)
          @selected.delete(active_choice)
        else
          @selected << active_choice
        end
      end

      private

      # Setup default options and active selection
      #
      # @api private
      def setup_defaults
        validate_defaults
        # At this stage, @choices matches all the visible choices.
        @selected = @choices.values_at(*@default.map { |d| d - 1 })
        @active = @default.last unless @selected.empty?
        if choices[@active - 1] && choices[@active - 1].disabled?
          raise ConfigurationError,
                "active choice '#{choices[@active - 1]}' matches disabled item"
        end
      end

      # Generate selected items names
      #
      # @return [String]
      #
      # @api private
      def selected_names
        @selected.map(&:name).join(', ')
      end

      # Render initial help text and then currently selected choices
      #
      # @api private
      def render_header
        instructions = @prompt.decorate(help, :bright_black)
        if @done && @echo
          @prompt.decorate(selected_names, @active_color)
        elsif @selected.size.nonzero? && @echo
          help_suffix = @filter.to_s != "" ? " #{filter_help}" : ""
          selected_names + (@first_render ? " #{instructions}" : help_suffix)
        elsif @first_render
          instructions
        elsif @filter.to_s != ""
          filter_help
        end
      end

      # All values for the choices selected
      #
      # @return [Array[nil,Object]]
      #
      # @api private
      def answer
        @selected.map(&:value)
      end

      # Render menu with choices to select from
      #
      # @return [String]
      #
      # @api private
      def render_menu
        output = []

        @paginator.paginate(choices, @active, @per_page) do |choice, index|
          num = enumerate? ? (index + 1).to_s + @enum + ' ' : ''
          indicator = (index + 1 == @active) ?  @marker : ' '
          indicator += ' '
          message = if @selected.include?(choice) && !choice.disabled?
                      selected = @prompt.decorate(symbols[:radio_on], @active_color)
                      selected + ' ' + num + choice.name
                    elsif choice.disabled?
                      @prompt.decorate(symbols[:cross], :red) +
                        ' ' + num + choice.name + ' ' + choice.disabled.to_s
                    else
                      symbols[:radio_off] + ' ' + num + choice.name
                    end
          max_index = paginated? ? @paginator.max_index : choices.size - 1
          newline = (index == max_index) ? '' : "\n"
          output << indicator + message + newline
        end

        output.join
      end
    end # MultiList
  end # Prompt
end # TTY
