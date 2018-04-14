# encoding: utf-8
# frozen_string_literal: true

require 'tty-cursor'
require 'tty-screen'
require 'wisper'

require_relative 'reader/history'
require_relative 'reader/line'
require_relative 'reader/key_event'
require_relative 'reader/console'
require_relative 'reader/win_console'
require_relative 'reader/version'

module TTY
  # A class responsible for reading character input from STDIN
  #
  # Used internally to provide key and line reading functionality
  #
  # @api public
  class Reader
    include Wisper::Publisher

    # Raised when the user hits the interrupt key(Control-C)
    #
    # @api public
    InputInterrupt = Class.new(StandardError)

    # Check if Windowz mode
    #
    # @return [Boolean]
    #
    # @api public
    def self.windows?
      ::File::ALT_SEPARATOR == '\\'
    end

    attr_reader :input

    attr_reader :output

    attr_reader :env

    attr_reader :track_history
    alias track_history? track_history

    attr_reader :console

    attr_reader :cursor

    # Key codes
    CARRIAGE_RETURN = 13
    NEWLINE         = 10
    BACKSPACE       = 8
    DELETE          = 127

    # Initialize a Reader
    #
    # @param [IO] input
    #   the input stream
    # @param [IO] output
    #   the output stream
    # @param [Hash] options
    # @option options [Symbol] :interrupt
    #   handling of Ctrl+C key out of :signal, :exit, :noop
    # @option options [Boolean] :track_history
    #   disable line history tracking, true by default
    #
    # @api public
    def initialize(**options)
      @input     = options.fetch(:input) { $stdin }
      @output    = options.fetch(:output) { $stdout }
      @interrupt = options.fetch(:interrupt) { :error }
      @env       = options.fetch(:env) { ENV }

      @track_history = options.fetch(:track_history) { true }
      @history_cycle = options.fetch(:history_cycle) { false }
      exclude_proc   = ->(line) { line.strip == '' }
      @history_exclude    = options.fetch(:history_exclude) { exclude_proc }
      @history_duplicates = options.fetch(:history_duplicates) { false }

      @console   = select_console(input)
      @history   = History.new do |h|
        h.cycle = @history_cycle
        h.duplicates = @history_duplicates
        h.exclude = @history_exclude
      end
      @stop = false # gathering input
      @cursor = TTY::Cursor

      subscribe(self)
    end

    # Select appropriate console
    #
    # @api private
    def select_console(input)
      if self.class.windows? && !env['TTY_TEST']
        WinConsole.new(input)
      else
        Console.new(input)
      end
    end

    # Get input in unbuffered mode.
    #
    # @example
    #   unbufferred do
    #     ...
    #   end
    #
    # @api public
    def unbufferred(&block)
      bufferring = output.sync
      # Immediately flush output
      output.sync = true
      block[] if block_given?
    ensure
      output.sync = bufferring
    end

    # Read a keypress  including invisible multibyte codes
    # and return a character as a string.
    # Nothing is echoed to the console. This call will block for a
    # single keypress, but will not wait for Enter to be pressed.
    #
    # @param [Hash[Symbol]] options
    # @option options [Boolean] echo
    #   whether to echo chars back or not, defaults to false
    # @option options [Boolean] raw
    #   whenther raw mode enabled, defaults to true
    #
    # @return [String]
    #
    # @api public
    def read_keypress(options = {})
      opts  = { echo: false, raw: true }.merge(options)
      codes = unbufferred { get_codes(opts) }
      char  = codes ? codes.pack('U*') : nil

      trigger_key_event(char) if char
      char
    end
    alias read_char read_keypress

    # Get input code points
    #
    # @param [Hash[Symbol]] options
    # @param [Array[Integer]] codes
    #
    # @return [Array[Integer]]
    #
    # @api private
    def get_codes(options = {}, codes = [])
      opts = { echo: true, raw: false }.merge(options)
      char = console.get_char(opts)
      handle_interrupt if console.keys[char] == :ctrl_c
      return if char.nil?
      codes << char.ord

      condition = proc { |escape|
        (codes - escape).empty? ||
        (escape - codes).empty? &&
        !(64..126).cover?(codes.last)
      }

      while console.escape_codes.any?(&condition)
        get_codes(options, codes)
      end
      codes
    end

    # Get a single line from STDIN. Each key pressed is echoed
    # back to the shell. The input terminates when enter or
    # return key is pressed.
    #
    # @param [String] prompt
    #   the prompt to display before input
    #
    # @param [Boolean] echo
    #   if true echo back characters, output nothing otherwise
    #
    # @return [String]
    #
    # @api public
    def read_line(prompt = '', **options)
      opts = { echo: true, raw: true }.merge(options)
      line = Line.new(prompt, '')
      screen_width = TTY::Screen.width

      output.print(line.prompt)

      while (codes = get_codes(opts)) && (code = codes[0])
        char = codes.pack('U*')
        trigger_key_event(char)

        break if [:ctrl_d, :ctrl_z].include?(console.keys[char])

        if opts[:raw] && opts[:echo]
          clear_display(line, screen_width)
        end

        if console.keys[char] == :backspace || BACKSPACE == code
          if !line.start?
            line.left
            line.delete
          end
        elsif console.keys[char] == :delete || DELETE == code
          line.delete
        elsif console.keys[char].to_s =~ /ctrl_/
          # skip
        elsif console.keys[char] == :up
          line.replace(history_previous) if history_previous?
        elsif console.keys[char] == :down
          line.replace(history_next? ? history_next : '')
        elsif console.keys[char] == :left
          line.left
        elsif console.keys[char] == :right
          line.right
        elsif console.keys[char] == :home
          line.move_to_start
        elsif console.keys[char] == :end
          line.move_to_end
        else
          if opts[:raw] && code == CARRIAGE_RETURN
            char = "\n"
            line.move_to_end
          end
          line.insert(char)
        end

        if (console.keys[char] == :backspace || BACKSPACE == code) && opts[:echo]
          if opts[:raw]
            output.print("\e[1X") unless line.start?
          else
            output.print(?\s + (line.start? ? '' : ?\b))
          end
        end

        if opts[:raw] && opts[:echo]
          output.print(line.to_s)
          if char == "\n"
            line.move_to_start
          elsif !line.end? # readjust cursor position
            output.print(cursor.backward(line.text_size - line.cursor))
          end
        end

        if [CARRIAGE_RETURN, NEWLINE].include?(code)
          output.puts unless opts[:echo]
          break
        end
      end
      if track_history? && opts[:echo]
        add_to_history(line.text.rstrip)
      end
      line.text
    end

    # Clear display for the current line input
    #
    # Handles clearing input that is longer than the current
    # terminal width which allows copy & pasting long strings.
    #
    # @param [Line] line
    #   the line to display
    # @param [Number] screen_width
    #   the terminal screen width
    #
    # @api private
    def clear_display(line, screen_width)
      total_lines  = count_screen_lines(line.size, screen_width)
      current_line = count_screen_lines(line.prompt_size + line.cursor, screen_width)
      lines_down = total_lines - current_line

      output.print(cursor.down(lines_down)) unless lines_down.zero?
      output.print(cursor.clear_lines(total_lines))
    end

    # Count the number of screen lines given line takes up in terminal
    #
    # @param [Integer] line_or_size
    #   the current line or its length
    # @param [Integer] screen_width
    #   the width of terminal screen
    #
    # @return [Integer]
    #
    # @api public
    def count_screen_lines(line_or_size, screen_width = TTY::Screen.width)
      line_size = if line_or_size.is_a?(Integer)
                    line_or_size
                  else
                    Line.sanitize(line_or_size).size
                  end
      # new character + we don't want to add new line on screen_width
      new_chars = self.class.windows? ? -1 : 1
      1 + [0, (line_size - new_chars) / screen_width].max
    end

    # Read multiple lines and return them in an array.
    # Skip empty lines in the returned lines array.
    # The input gathering is terminated by Ctrl+d or Ctrl+z.
    #
    # @param [String] prompt
    #   the prompt displayed before the input
    #
    # @yield [String] line
    #
    # @return [Array[String]]
    #
    # @api public
    def read_multiline(*args)
      @stop = false
      lines = []
      loop do
        line = read_line(*args)
        break if !line || line == ''
        next  if line !~ /\S/ && !@stop
        if block_given?
          yield(line) unless line.to_s.empty?
        else
          lines << line unless line.to_s.empty?
        end
        break if @stop
      end
      lines
    end
    alias read_lines read_multiline

    # Expose event broadcasting
    #
    # @api public
    def trigger(event, *args)
      publish(event, *args)
    end

    # Capture Ctrl+d and Ctrl+z key events
    #
    # @api private
    def keyctrl_d(*)
      @stop = true
    end
    alias keyctrl_z keyctrl_d

    def add_to_history(line)
      @history.push(line)
    end

    def history_next?
      @history.next?
    end

    def history_next
      @history.next
      @history.get
    end

    def history_previous?
      @history.previous?
    end

    def history_previous
      line = @history.get
      @history.previous
      line
    end

    # Inspect class name and public attributes
    # @return [String]
    #
    # @api public
    def inspect
      "#<#{self.class}: @input=#{input}, @output=#{output}>"
    end

    private

    # Publish event
    #
    # @param [String] char
    #   the key pressed
    #
    # @return [nil]
    #
    # @api private
    def trigger_key_event(char)
      event = KeyEvent.from(console.keys, char)
      trigger(:"key#{event.key.name}", event) if event.trigger?
      trigger(:keypress, event)
    end

    # Handle input interrupt based on provided value
    #
    # @api private
    def handle_interrupt
      case @interrupt
      when :signal
        Process.kill('SIGINT', Process.pid)
      when :exit
        exit(130)
      when Proc
        @interrupt.call
      when :noop
        return
      else
        raise InputInterrupt
      end
    end
  end # Reader
end # TTY
