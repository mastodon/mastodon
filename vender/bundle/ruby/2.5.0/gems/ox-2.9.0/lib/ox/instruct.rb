
module Ox

  # An Instruct represents a processing instruction of an XML document. It has a target, attributes, and a value or
  # content. The content will be all characters with the exception of the target. If the content follows a regular
  # attribute format then the attributes will be set to the parsed values. If it does not follow the attribute formate
  # then the attributes will be empty.
  class Instruct < Node
    include HasAttrs

    # The content of the processing instruction.
    attr_accessor :content

    # Creates a new Instruct with the specified name.
    # - +name+ [String] name of the Instruct
    def initialize(name)
      super
      @attributes = nil
      @content = nil
    end
    alias target value
    
    # Returns true if this Object and other are of the same type and have the
    # equivalent value and the equivalent elements otherwise false is returned.
    # - +other+ [Object] Object compare _self_ to.
    # *return* [Boolean] true if both Objects are equivalent, otherwise false.
    def eql?(other)
      return false unless super(other)
      return false unless self.attributes == other.attributes
      return false unless self.content == other.content
      true
    end
    alias == eql?
    
  end # Instruct
end # Ox
