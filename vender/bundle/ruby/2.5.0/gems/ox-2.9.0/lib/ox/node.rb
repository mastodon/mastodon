
module Ox
  # The Node is the base class for all other in the Ox module.
  class Node
    # String value associated with the Node.
    attr_accessor :value
    
    # Creates a new Node with the specified String value.
    # - +value+ [String] string value for the Node
    def initialize(value)
      @value = value.to_s
    end

    # Returns true if this Object and other are of the same type and have the
    # equivalent value otherwise false is returned.
    # - +other+ [Object] Object to compare _self_ to.
    def eql?(other)
      return false if (other.nil? or self.class != other.class)
      other.value == self.value
    end
    alias == eql?

  end # Node
end # Ox
