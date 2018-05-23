module MessagePack

  #
  # MessagePack::ExtensionValue is a struct to represent unknown ext type object.
  # Its contents are accessed by type and payload (messagepack bytes representation) methods.
  # And it is extended to add to_msgpack object.
  #
  ExtensionValue = Struct.new(:type, :payload)
end
