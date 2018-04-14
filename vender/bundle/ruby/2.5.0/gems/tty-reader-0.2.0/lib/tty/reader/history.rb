# encoding: utf-8
# frozen_string_literal: true

require 'forwardable'

module TTY
  class Reader
    # A class responsible for storing a history of all lines entered by
    # user when interacting with shell prompt.
    #
    # @api private
    class History
      include Enumerable
      extend Forwardable

      # Default maximum size
      DEFAULT_SIZE = 32 << 4

      def_delegators :@history, :size, :length, :to_s, :inspect

      # Set and retrieve the maximum size of the buffer
      attr_accessor :max_size

      attr_reader :index

      attr_accessor :cycle

      attr_accessor :duplicates

      attr_accessor :exclude

      # Create a History buffer
      #
      # param [Integer] max_size
      #   the maximum size for history buffer
      #
      # param [Hash[Symbol]] options
      # @option options [Boolean] :cycle
      #   whether or not the history should cycle, false by default
      # @option options [Boolean] :duplicates
      #   whether or not to store duplicates, true by default
      # @option options [Boolean] :exclude
      #   a Proc to exclude items from storing in history
      #
      # @api public
      def initialize(max_size = DEFAULT_SIZE, **options)
        @max_size   = max_size
        @index      = nil
        @history    = []
        @duplicates = options.fetch(:duplicates) { true }
        @exclude    = options.fetch(:exclude) { proc {} }
        @cycle      = options.fetch(:cycle) { false }
        yield self if block_given?
      end

      # Iterates over history lines
      #
      # @api public
      def each
        if block_given?
          @history.each { |line| yield line }
        else
          @history.to_enum
        end
      end

      # Add the last typed line to history buffer
      #
      # @param [String] line
      #
      # @api public
      def push(line)
        @history.delete(line) unless @duplicates
        return if line.to_s.empty? || @exclude[line]

        @history.shift if size >= max_size
        @history << line
        @index = @history.size - 1

        self
      end
      alias << push

      # Move the pointer to the next line in the history
      #
      # @api public
      def next
        return if size.zero?
        if @index == size - 1
          @index = 0 if @cycle
        else
          @index += 1
        end
      end

      def next?
        size > 0 && !(@index == size - 1 && !@cycle)
      end

      # Move the pointer to the previous line in the history
      def previous
        return if size.zero?
        if @index.zero?
          @index = size - 1 if @cycle
        else
          @index -= 1
        end
      end

      def previous?
        size > 0 && !(@index < 0 && !@cycle)
      end

      # Return line at the specified index
      #
      # @raise [IndexError] index out of range
      #
      # @api public
      def [](index)
        if index < 0
          index += @history.size if index < 0
        end
        line = @history[index]
        if line.nil?
          raise IndexError, 'invalid index'
        end
        line.dup
      end

      # Get current line
      #
      # @api public
      def get
        return if size.zero?

        self[@index]
      end

      # Empty all history lines
      #
      # @api public
      def clear
        @history.clear
        @index = 0
      end
    end # History
  end # Reader
end # TTY
