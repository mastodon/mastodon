# encoding: utf-8

require_relative 'ansi'

module Pastel
  # Responsible for parsing color symbols out of text with color escapes
  #
  # Used internally by {Color}.
  #
  # @api private
  class ColorParser
    include ANSI

    ESC = "\x1b".freeze
    CSI = "\[".freeze

    # Parse color escape sequences into a list of hashes
    # corresponding to the color attributes being set by these
    # sequences
    #
    # @example
    #   parse("\e[32mfoo\e[0m") # => [{colors: [:green], text: 'foo'}
    #
    # @param [String] text
    #   the text to parse for presence of color ansi codes
    #
    # @return [Array[Hash[Symbol,String]]]
    #
    # @api public
    def self.parse(text)
      scanner = StringScanner.new(text)
      state = {}
      result = []
      ansi_stack = []
      text_chunk = ''

      until scanner.eos?
        char = scanner.getch
        # match control
        if char == ESC && (delim = scanner.getch) == CSI
          if scanner.scan(/^0m/)
            unpack_ansi(ansi_stack) { |attr, name| state[attr] = name }
            ansi_stack = []
          elsif scanner.scan(/^([1-9;:]+)m/)
            # ansi codes separated by text
            if !text_chunk.empty? && !ansi_stack.empty?
              unpack_ansi(ansi_stack) { |attr, name| state[attr] = name }
              ansi_stack = []
            end
            scanner[1].split(/:|;/).each do |code|
              ansi_stack << code
            end
          end

          if !text_chunk.empty?
            state[:text] = text_chunk
            result.push(state)
            state = {}
            text_chunk = ''
          end
        elsif char == ESC # broken escape
          text_chunk << char + delim.to_s
        else
          text_chunk << char
        end
      end

      if !text_chunk.empty?
        state[:text] = text_chunk
      end
      if !ansi_stack.empty?
        unpack_ansi(ansi_stack) { |attr, name| state[attr] = name}
      end
      if state.values.any? { |val| !val.empty? }
        result.push(state)
      end
      result
    end

    # Remove from current stack all ansi codes
    #
    # @param [Array[Integer]] ansi_stack
    #   the stack with all the ansi codes
    #
    # @yield [Symbol, Symbol] attr, name
    #
    # @api private
    def self.unpack_ansi(ansi_stack)
      ansi_stack.each do |ansi|
        name = ansi_for(ansi)
        attr = attribute_for(ansi)
        yield attr, name
      end
    end

    # Decide attribute name for ansi
    #
    # @param [Integer] ansi
    #   the ansi escape code
    #
    # @return [Symbol]
    #
    # @api private
    def self.attribute_for(ansi)
      if ANSI.foreground?(ansi)
        :foreground
      elsif ANSI.background?(ansi)
        :background
      elsif ANSI.style?(ansi)
        :style
      end
    end

    # @api private
    def self.ansi_for(ansi)
      ATTRIBUTES.key(ansi.to_i)
    end
  end # Parser
end # Pastel
