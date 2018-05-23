# frozen_string_literal: true

module NIO
  # Efficient byte buffers for performant I/O operations
  class ByteBuffer
    include Enumerable

    attr_reader :position, :limit, :capacity

    # Insufficient capacity in buffer
    OverflowError = Class.new(IOError)

    # Not enough data remaining in buffer
    UnderflowError = Class.new(IOError)

    # Mark has not been set
    MarkUnsetError = Class.new(IOError)

    # Create a new ByteBuffer, either with a specified capacity or populating
    # it from a given string
    #
    # @param capacity [Integer] size of buffer in bytes
    #
    # @return [NIO::ByteBuffer]
    def initialize(capacity)
      raise TypeError, "no implicit conversion of #{capacity.class} to Integer" unless capacity.is_a?(Integer)
      @capacity = capacity
      clear
    end

    # Clear the buffer, resetting it to the default state
    def clear
      @buffer   = ("\0" * @capacity).force_encoding(Encoding::BINARY)
      @position = 0
      @limit    = @capacity
      @mark     = nil

      self
    end

    # Set the position to the given value. New position must be less than limit.
    # Preserves mark if it's less than the new position, otherwise clears it.
    #
    # @param new_position [Integer] position in the buffer
    #
    # @raise [ArgumentError] new position was invalid
    def position=(new_position)
      raise ArgumentError, "negative position given" if new_position < 0
      raise ArgumentError, "specified position exceeds capacity" if new_position > @capacity

      @mark = nil if @mark && @mark > new_position
      @position = new_position
    end

    # Set the limit to the given value. New limit must be less than capacity.
    # Preserves limit and mark if they're less than the new limit, otherwise
    # sets position to the new limit and clears the mark.
    #
    # @param new_limit [Integer] position in the buffer
    #
    # @raise [ArgumentError] new limit was invalid
    def limit=(new_limit)
      raise ArgumentError, "negative limit given" if new_limit < 0
      raise ArgumentError, "specified limit exceeds capacity" if new_limit > @capacity

      @position = new_limit if @position > new_limit
      @mark = nil if @mark && @mark > new_limit
      @limit = new_limit
    end

    # Number of bytes remaining in the buffer before the limit
    #
    # @return [Integer] number of bytes remaining
    def remaining
      @limit - @position
    end

    # Does the ByteBuffer have any space remaining?
    #
    # @return [true, false]
    def full?
      remaining.zero?
    end

    # Obtain the requested number of bytes from the buffer, advancing the position.
    # If no length is given, all remaining bytes are consumed.
    #
    # @raise [NIO::ByteBuffer::UnderflowError] not enough data remaining in buffer
    #
    # @return [String] bytes read from buffer
    def get(length = remaining)
      raise ArgumentError, "negative length given" if length < 0
      raise UnderflowError, "not enough data in buffer" if length > @limit - @position

      result = @buffer[@position...length]
      @position += length
      result
    end

    # Obtain the byte at a given index in the buffer as an Integer
    #
    # @raise [ArgumentError] index is invalid (either negative or larger than limit)
    #
    # @return [Integer] byte at the given index
    def [](index)
      raise ArgumentError, "negative index given" if index < 0
      raise ArgumentError, "specified index exceeds limit" if index >= @limit

      @buffer.bytes[index]
    end

    # Add a String to the buffer
    #
    # @param str [#to_str] data to add to the buffer
    #
    # @raise [TypeError] given a non-string type
    # @raise [NIO::ByteBuffer::OverflowError] buffer is full
    #
    # @return [self]
    def put(str)
      raise TypeError, "expected String, got #{str.class}" unless str.respond_to?(:to_str)
      str = str.to_str

      raise OverflowError, "buffer is full" if str.length > @limit - @position
      @buffer[@position...str.length] = str
      @position += str.length
      self
    end
    alias << put

    # Perform a non-blocking read from the given IO object into the buffer
    # Reads as much data as is immediately available and returns
    #
    # @param [IO] Ruby IO object to read from
    #
    # @return [Integer] number of bytes read (0 if none were available)
    def read_from(io)
      nbytes = @limit - @position
      raise OverflowError, "buffer is full" if nbytes.zero?

      bytes_read = IO.try_convert(io).read_nonblock(nbytes, exception: false)
      return 0 if bytes_read == :wait_readable

      self << bytes_read
      bytes_read.length
    end

    # Perform a non-blocking write of the buffer's contents to the given I/O object
    # Writes as much data as is immediately possible and returns
    #
    # @param [IO] Ruby IO object to write to
    #
    # @return [Integer] number of bytes written (0 if the write would block)
    def write_to(io)
      nbytes = @limit - @position
      raise UnderflowError, "no data remaining in buffer" if nbytes.zero?

      bytes_written = IO.try_convert(io).write_nonblock(@buffer[@position...@limit], exception: false)
      return 0 if bytes_written == :wait_writable

      @position += bytes_written
      bytes_written
    end

    # Set the buffer's current position as the limit and set the position to 0
    def flip
      @limit = @position
      @position = 0
      @mark = nil
      self
    end

    # Set the buffer's current position to 0, leaving the limit unchanged
    def rewind
      @position = 0
      @mark = nil
      self
    end

    # Mark a position to return to using the `#reset` method
    def mark
      @mark = @position
      self
    end

    # Reset position to the previously marked location
    #
    # @raise [NIO::ByteBuffer::MarkUnsetError] mark has not been set (call `#mark` first)
    def reset
      raise MarkUnsetError, "mark has not been set" unless @mark
      @position = @mark
      self
    end

    # Move data between the position and limit to the beginning of the buffer
    # Sets the position to the end of the moved data, and the limit to the capacity
    def compact
      @buffer[0...(@limit - @position)] = @buffer[@position...@limit]
      @position = @limit - @position
      @limit = capacity
      self
    end

    # Iterate over the bytes in the buffer (as Integers)
    #
    # @return [self]
    def each(&block)
      @buffer[0...@limit].each_byte(&block)
    end

    # Inspect the state of the buffer
    #
    # @return [String] string describing the state of the buffer
    def inspect
      format(
        "#<%s:0x%x @position=%d @limit=%d @capacity=%d>",
        self.class,
        object_id << 1,
        @position,
        @limit,
        @capacity
      )
    end
  end
end
