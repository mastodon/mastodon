# encoding: utf-8

module TTY
  module Color
    class Support
      SOURCES = %w(from_term from_tput from_env from_curses).freeze

      # Initialize a color support
      # @api public
      def initialize(env, options = {})
        @env = env
        @verbose = options.fetch(:verbose) { false }
      end

      # Detect if terminal supports color
      #
      # @return [Boolean]
      #   true when terminal supports color, false otherwise
      #
      # @api public
      def supports?
        return false unless TTY::Color.tty?

        value = false
        SOURCES.each do |from_check|
          break if (value = public_send(from_check)) != NoValue
        end
        return false if value == NoValue
        value
      end

      # Inspect environment $TERM variable for color support
      #
      # @api private
      def from_term
        case @env['TERM']
        when 'dumb' then false
        when /^screen|^xterm|^vt100|color|ansi|cygwin|linux/i then true
        else NoValue
        end
      end

      # Shell out to tput to check color support
      #
      # @api private
      def from_tput
        cmd = %q(tput colors 2>/dev/null)
        if !TTY::Color.command?("tput colors")
          return NoValue
        end
        `#{cmd}`.to_i > 2
      rescue Errno::ENOENT
        NoValue
      end

      # Check if environment specifies color variables
      #
      # @api private
      def from_env
        ['COLORTERM', 'ANSICON'].any? { |key| @env.key?(key) } || NoValue
      end

      # Attempt to load curses to check color support
      #
      # @return [Boolean]
      #
      # @api private
      def from_curses(curses_class = nil)
        return NoValue if TTY::Color.windows?
        require 'curses'

        if defined?(Curses)
          curses_class ||= Curses
          curses_class.init_screen
          has_color = curses_class.has_colors?
          curses_class.close_screen
          return has_color
        end
        NoValue
      rescue LoadError
        warn 'no native curses support' if @verbose
        NoValue
      end
    end # Support
  end # Color
end # TTY
