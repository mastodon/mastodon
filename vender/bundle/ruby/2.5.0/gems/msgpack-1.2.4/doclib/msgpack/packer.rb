module MessagePack

  #
  # MessagePack::Packer is a class to serialize objects.
  #
  class Packer
    #
    # Creates a MessagePack::Packer instance.
    # See Buffer#initialize for supported options.
    #
    # @overload initialize(options={})
    #   @param options [Hash]
    #
    # @overload initialize(io, options={})
    #   @param io [IO]
    #   @param options [Hash]
    #   This packer writes serialzied objects into the IO when the internal buffer is filled.
    #   _io_ must respond to write(string) or append(string) method.
    #
    # Supported options:
    #
    # * *:compatibility_mode* serialize in older versions way, without str8 and bin types
    #
    # See also Buffer#initialize for other options.
    #
    def initialize(*args)
    end

    #
    # Register a new ext type to serialize it. This method should be called with one of
    # method name or block, which returns bytes(ASCII-8BIT String) representation of
    # object to be serialized.
    #
    # @overload register_type(type, klass, &block)
    #   @param type [Fixnum] type id (0-127) user defined type id for specified Class
    #   @param klass [Class] Class to be serialized with speicifed type id
    #   @yieldparam object [Object] object to be serialized
    #
    # @overload register_type(type, klass, method_name)
    #   @param type [Fixnum] type id (0-127) user defined type id for specified Class
    #   @param klass [Class] Class to be serialized with speicifed type id
    #   @param method_name [Symbol] method which returns bytes of serialized representation
    #
    # @return nil
    #
    def register_type(type, klass, method_name, &block)
    end

    #
    # Returns a list of registered types, ordered by type id.
    # Each element is a Hash object includes keys :type, :class and :packer.
    #
    # @return Array
    #
    def registered_types
    end

    #
    # Returns true/false which indicate specified class or type id is registered or not.
    #
    # @param klass_or_type [Class or Fixnum] Class or type id (0-127) to be checked
    # @return true or false
    #
    def type_registered?(klass_or_type)
    end

    #
    # Internal buffer
    #
    # @return MessagePack::Buffer
    #
    attr_reader :buffer

    #
    # Serializes an object into internal buffer, and flushes to io if necessary.
    #
    # If it could not serialize the object, it raises
    # NoMethodError: undefined method `to_msgpack' for #<the_object>.
    #
    # @param obj [Object] object to serialize
    # @return [Packer] self
    #
    def write(obj)
    end

    alias pack write

    #
    # Serializes a nil object. Same as write(nil).
    #
    def write_nil
    end

    #
    # Write a header of an array whose size is _n_.
    # For example, write_array_header(1).write(true) is same as write([ true ]).
    #
    # @return [Packer] self
    #
    def write_array_header(n)
    end

    #
    # Write a header of an map whose size is _n_.
    # For example, write_map_header(1).write('key').write(true) is same as write('key'=>true).
    #
    # @return [Packer] self
    #
    def write_map_header(n)
    end

    #
    # Serializes _value_ as 32-bit single precision float into internal buffer.
    # _value_ will be approximated with the nearest possible single precision float, thus
    # being potentially lossy. However, the serialized string will only take up 5 bytes
    # instead of 9 bytes compared to directly serializing a 64-bit double precision Ruby Float.
    #
    # @param value [Numeric]
    # @return [Packer] self
    #
    def write_float32(value)
    end

    #
    # Flushes data in the internal buffer to the internal IO. Same as _buffer.flush.
    # If internal IO is not set, it does nothing.
    #
    # @return [Packer] self
    #
    def flush
    end

    #
    # Makes the internal buffer empty. Same as _buffer.clear_.
    #
    # @return nil
    #
    def clear
    end

    #
    # Returns size of the internal buffer. Same as buffer.size.
    #
    # @return [Integer]
    #
    def size
    end

    #
    # Returns _true_ if the internal buffer is empty. Same as buffer.empty?.
    # This method is slightly faster than _size_.
    #
    # @return [Boolean]
    #
    def empty?
    end

    #
    # Returns all data in the buffer as a string. Same as buffer.to_str.
    #
    # @return [String]
    #
    def to_str
    end

    alias to_s to_str

    #
    # Returns content of the internal buffer as an array of strings. Same as buffer.to_a.
    # This method is faster than _to_str_.
    #
    # @return [Array] array of strings
    #
    def to_a
    end

    #
    # Writes all of data in the internal buffer into the given IO. Same as buffer.write_to(io).
    # This method consumes and removes data from the internal buffer.
    # _io_ must respond to write(data) method.
    #
    # @param io [IO]
    # @return [Integer] byte size of written data
    #
    def write_to(io)
    end
  end
end
