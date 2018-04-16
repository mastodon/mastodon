# encoding: utf-8
# frozen_string_literal: true

require_relative 'keys'

module TTY
  class Reader
    class WinConsole
      ESC     = "\e".freeze
      NUL_HEX = "\x00".freeze
      EXT_HEX = "\xE0".freeze

      # Key codes
      #
      # @return [Hash[Symbol]]
      #
      # @api public
      attr_reader :keys

      # Escape codes
      #
      # @return [Array[Integer]]
      #
      # @api public
      attr_reader :escape_codes

      def initialize(input)
        require_relative 'win_api'
        @input = input
        @keys = Keys.ctrl_keys.merge(Keys.win_keys)
        @escape_codes = [[NUL_HEX.ord], [ESC.ord], EXT_HEX.bytes.to_a]
      end

      # Get a character from console blocking for input
      #
      # @param [Hash[Symbol]] options
      # @option options [Symbol] :echo
      #   the echo mode toggle
      # @option options [Symbol] :raw
      #   the raw mode toggle
      #
      # @return [String]
      #
      # @api private
      def get_char(options)
        if options[:raw] && options[:echo]
          if options[:nonblock]
            get_char_echo_non_blocking
          else
            get_char_echo_blocking
          end
        elsif options[:raw] && !options[:echo]
          options[:nonblock] ? get_char_non_blocking : get_char_blocking
        elsif !options[:raw] && !options[:echo]
          options[:nonblock] ? get_char_non_blocking : get_char_blocking
        else
          @input.getc
        end
      end

      # Get the char for last key pressed, or if no keypress return nil
      #
      # @api private
      def get_char_non_blocking
        input_ready? ? get_char_blocking : nil
      end

      def get_char_echo_non_blocking
        input_ready? ? get_char_echo_blocking : nil
      end

      def get_char_blocking
        WinAPI.getch.chr
      end

      def get_char_echo_blocking
        WinAPI.getche.chr
      end

      # Check if IO has user input
      #
      # @return [Boolean]
      #
      # @api private
      def input_ready?
        !WinAPI.kbhit.zero?
      end
    end # Console
  end # Reader
end # TTY
