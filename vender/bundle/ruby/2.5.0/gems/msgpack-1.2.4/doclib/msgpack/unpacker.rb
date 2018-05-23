module MessagePack

  #
  # MessagePack::Unpacker is a class to deserialize objects.
  #
  class Unpacker
    #
    # Creates a MessagePack::Unpacker instance.
    #
    # @overload initialize(options={})
    #   @param options [Hash]
    #
    # @overload initialize(io, options={})
    #   @param io [IO]
    #   @param options [Hash]
    #   This unpacker reads data from the _io_ to fill the internal buffer.
    #   _io_ must respond to readpartial(length [,string]) or read(length [,string]) method.
    #
    # Supported options:
    #
    # * *:symbolize_keys* deserialize keys of Hash objects as Symbol instead of String
    # * *:allow_unknown_ext* allow to deserialize ext type object with unknown type id as ExtensionValue instance. Otherwise (by default), unpacker throws UnknownExtTypeError.
    #
    # See also Buffer#initialize for other options.
    #
    def initialize(*args)
    end

    #
    # Register a new ext type to deserialize it. This method should be called with
    # Class and its class method name, or block, which returns a instance object.
    #
    # @overload register_type(type, &block)
    #   @param type [Fixnum] type id (0-127) user defined type id for specified deserializer block
    #   @yieldparam data [String] bytes(ASCII-8BIT String) represents serialized object, to be deserialized
    #
    # @overload register_type(type, klass, class_method_name)
    #   @param type [Fixnum] type id (0-127) user defined type id for specified Class
    #   @param klass [Class] Class to be serialized with speicifed type id
    #   @param class_method_name [Symbol] class method which returns an instance object
    #
    # @return nil
    #
    def register_type(type, klass, method_name, &block)
    end

    #
    # Returns a list of registered types, ordered by type id.
    # Each element is a Hash object includes keys :type, :class and :unpacker.
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
    # @return [MessagePack::Buffer]
    #
    attr_reader :buffer

    #
    # Deserializes an object from the io or internal buffer and returns it.
    #
    # This method reads data from io into the internal buffer and deserializes an object
    # from the buffer. It repeats reading data from the io until enough data is available
    # to deserialize at least one object. After deserializing one object, unused data is
    # left in the internal buffer.
    #
    # If there're not enough data to deserialize one object, this method raises EOFError.
    # If data format is invalid, this method raises MessagePack::MalformedFormatError.
    # If the object nests too deeply, this method raises MessagePack::StackError.
    #
    # @return [Object] deserialized object
    #
    def read
    end

    alias unpack read

    #
    # Deserializes an object and ignores it. This method is faster than _read_.
    #
    # This method could raise the same errors with _read_.
    #
    # @return nil
    #
    def skip
    end

    #
    # Deserializes a nil value if it exists and returns _true_.
    # Otherwise, if a byte exists but the byte doesn't represent nil value,
    # returns _false_.
    #
    # If there're not enough data, this method raises EOFError.
    #
    # @return [Boolean]
    #
    def skip_nil
    end

    #
    # Read a header of an array and returns its size.
    # It converts a serialized array into a stream of elements.
    #
    # If the serialized object is not an array, it raises MessagePack::UnexpectedTypeError.
    # If there're not enough data, this method raises EOFError.
    #
    # @return [Integer] size of the array
    #
    def read_array_header
    end

    #
    # Reads a header of an map and returns its size.
    # It converts a serialized map into a stream of key-value pairs.
    #
    # If the serialized object is not a map, it raises MessagePack::UnexpectedTypeError.
    # If there're not enough data, this method raises EOFError.
    #
    # @return [Integer] size of the map
    #
    def read_map_header
    end

    #
    # Appends data into the internal buffer.
    # This method is equivalent to unpacker.buffer.append(data).
    #
    # @param data [String]
    # @return [Unpacker] self
    #
    def feed(data)
    end

    #
    # Repeats to deserialize objects.
    #
    # It repeats until the io or internal buffer does not include any complete objects.
    #
    # If the an IO is set, it repeats to read data from the IO when the buffer
    # becomes empty until the IO raises EOFError.
    #
    # This method could raise same errors with _read_ excepting EOFError.
    #
    # @yieldparam object [Object] deserialized object
    # @return nil
    #
    def each(&block)
    end

    #
    # Appends data into the internal buffer and repeats to deserialize objects.
    # This method is equivalent to unpacker.feed(data) && unpacker.each { ... }.
    #
    # @param data [String]
    # @yieldparam object [Object] deserialized object
    # @return nil
    #
    def feed_each(data, &block)
    end

    #
    # Clears the internal buffer and resets deserialization state of the unpacker.
    #
    # @return nil
    #
    def reset
    end
  end

end
