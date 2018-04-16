
module MessagePack
  #
  # Serializes an object into an IO or String.
  #
  # @overload dump(obj, options={})
  #   @param obj [Object] object to be serialized
  #   @param options [Hash]
  #   @return [String] serialized data
  #
  # @overload dump(obj, io, options={})
  #   @param obj [Object] object to be serialized
  #   @param io [IO]
  #   @param options [Hash]
  #   @return [IO]
  #
  # See Packer#initialize for supported options.
  #
  def self.dump(obj)
  end

  #
  # Serializes an object into an IO or String. Alias of dump.
  #
  # @overload pack(obj, options={})
  #   @param obj [Object] object to be serialized
  #   @param options [Hash]
  #   @return [String] serialized data
  #
  # @overload pack(obj, io, options={})
  #   @param obj [Object] object to be serialized
  #   @param io [IO]
  #   @param options [Hash]
  #   @return [IO]
  #
  # See Packer#initialize for supported options.
  #
  def self.pack(obj)
  end

  #
  # Deserializes an object from an IO or String.
  #
  # @overload load(string, options={})
  #   @param string [String] data to deserialize
  #   @param options [Hash]
  #
  # @overload load(io, options={})
  #   @param io [IO]
  #   @param options [Hash]
  #
  # @return [Object] deserialized object
  #
  # See Unpacker#initialize for supported options.
  #
  def self.load(src, options={})
  end

  #
  # Deserializes an object from an IO or String. Alias of load.
  #
  # @overload unpack(string, options={})
  #   @param string [String] data to deserialize
  #   @param options [Hash]
  #
  # @overload unpack(io, options={})
  #   @param io [IO]
  #   @param options [Hash]
  #
  # @return [Object] deserialized object
  #
  # See Unpacker#initialize for supported options.
  #
  def self.unpack(src, options={})
  end

  #
  # An instance of Factory class. DefaultFactory is also used
  # by global pack/unpack methods such as MessagePack.dump/load,
  # Hash#to_msgpack, and other to_msgpack methods.
  #
  # Calling DefaultFactory.register_type lets you add an extension
  # type globally.
  #
  DefaultFactory = Factory.new
end

