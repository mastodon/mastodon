require "thor/shell/basic"

class Thor
  module Shell
    # Inherit from Thor::Shell::Basic and add set_color behavior. Check
    # Thor::Shell::Basic to see all available methods.
    #
    class HTML < Basic
      # The start of an HTML bold sequence.
      BOLD       = "font-weight: bold"

      # Set the terminal's foreground HTML color to black.
      BLACK      = "color: black"
      # Set the terminal's foreground HTML color to red.
      RED        = "color: red"
      # Set the terminal's foreground HTML color to green.
      GREEN      = "color: green"
      # Set the terminal's foreground HTML color to yellow.
      YELLOW     = "color: yellow"
      # Set the terminal's foreground HTML color to blue.
      BLUE       = "color: blue"
      # Set the terminal's foreground HTML color to magenta.
      MAGENTA    = "color: magenta"
      # Set the terminal's foreground HTML color to cyan.
      CYAN       = "color: cyan"
      # Set the terminal's foreground HTML color to white.
      WHITE      = "color: white"

      # Set the terminal's background HTML color to black.
      ON_BLACK   = "background-color: black"
      # Set the terminal's background HTML color to red.
      ON_RED     = "background-color: red"
      # Set the terminal's background HTML color to green.
      ON_GREEN   = "background-color: green"
      # Set the terminal's background HTML color to yellow.
      ON_YELLOW  = "background-color: yellow"
      # Set the terminal's background HTML color to blue.
      ON_BLUE    = "background-color: blue"
      # Set the terminal's background HTML color to magenta.
      ON_MAGENTA = "background-color: magenta"
      # Set the terminal's background HTML color to cyan.
      ON_CYAN    = "background-color: cyan"
      # Set the terminal's background HTML color to white.
      ON_WHITE   = "background-color: white"

      # Set color by using a string or one of the defined constants. If a third
      # option is set to true, it also adds bold to the string. This is based
      # on Highline implementation and it automatically appends CLEAR to the end
      # of the returned String.
      #
      def set_color(string, *colors)
        if colors.all? { |color| color.is_a?(Symbol) || color.is_a?(String) }
          html_colors = colors.map { |color| lookup_color(color) }
          "<span style=\"#{html_colors.join('; ')};\">#{string}</span>"
        else
          color, bold = colors
          html_color = self.class.const_get(color.to_s.upcase) if color.is_a?(Symbol)
          styles = [html_color]
          styles << BOLD if bold
          "<span style=\"#{styles.join('; ')};\">#{string}</span>"
        end
      end

      # Ask something to the user and receives a response.
      #
      # ==== Example
      # ask("What is your name?")
      #
      # TODO: Implement #ask for Thor::Shell::HTML
      def ask(statement, color = nil)
        raise NotImplementedError, "Implement #ask for Thor::Shell::HTML"
      end

    protected

      def can_display_colors?
        true
      end

      # Overwrite show_diff to show diff with colors if Diff::LCS is
      # available.
      #
      def show_diff(destination, content) #:nodoc:
        if diff_lcs_loaded? && ENV["THOR_DIFF"].nil? && ENV["RAILS_DIFF"].nil?
          actual  = File.binread(destination).to_s.split("\n")
          content = content.to_s.split("\n")

          Diff::LCS.sdiff(actual, content).each do |diff|
            output_diff_line(diff)
          end
        else
          super
        end
      end

      def output_diff_line(diff) #:nodoc:
        case diff.action
        when "-"
          say "- #{diff.old_element.chomp}", :red, true
        when "+"
          say "+ #{diff.new_element.chomp}", :green, true
        when "!"
          say "- #{diff.old_element.chomp}", :red, true
          say "+ #{diff.new_element.chomp}", :green, true
        else
          say "  #{diff.old_element.chomp}", nil, true
        end
      end

      # Check if Diff::LCS is loaded. If it is, use it to create pretty output
      # for diff.
      #
      def diff_lcs_loaded? #:nodoc:
        return true if defined?(Diff::LCS)
        return @diff_lcs_loaded unless @diff_lcs_loaded.nil?

        @diff_lcs_loaded = begin
          require "diff/lcs"
          true
        rescue LoadError
          false
        end
      end
    end
  end
end
