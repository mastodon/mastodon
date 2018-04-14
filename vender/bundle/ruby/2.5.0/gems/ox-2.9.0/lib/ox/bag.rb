
module Ox

  # A generic class that is used only for storing attributes. It is the base
  # Class for auto-generated classes in the storage system. Instance variables
  # are added using the instance_variable_set() method. All instance variables
  # can be accessed using the variable name (without the @ prefix). No setters
  # are provided as the Class is intended for reading only.
  class Bag

    # The initializer can take multiple arguments in the form of key values
    # where the key is the variable name and the value is the variable
    # value. This is intended for testing purposes only.
    # - +args+ [Hash] instance variable symbols and their values
    #
    # *Example*
    #
    #  Ox::Bag.new(:@x => 42, :@y => 57)
    #
    def initialize(args={ })
      args.each do |k,v|
        self.instance_variable_set(k, v)
      end
    end

    # Replaces the Object.respond_to?() method.
    # - +m+ [Symbol] method symbol
    # *return* [Boolean] true for any method that matches an instance variable
    # reader, otherwise false.
    def respond_to?(m)
      return true if super
      at_m = ('@' + m.to_s).to_sym
      instance_variables.include?(at_m)
    end

    # Handles requests for variable values. Others cause an Exception to be
    # raised.
    # - +m+ (Symbol) method symbol
    # *return* [Boolean] the value of the specified instance variable.
    #
    # _raise_ [ArgumentError] if an argument is given. Zero arguments expected.
    #
    # _raise_ [NoMethodError] if the instance variable is not defined.
    def method_missing(m, *args, &block)
      raise ArgumentError.new("wrong number of arguments (#{args.size} for 0) to method #{m}") unless args.nil? or args.empty?
      at_m = ('@' + m.to_s).to_sym
      raise NoMethodError.new("undefined method #{m}", m) unless instance_variable_defined?(at_m)
      instance_variable_get(at_m)
    end

    # Replaces eql?() with something more reasonable for this Class.
    # - +other+ [Object] Object to compare self to
    # *return* [Boolean] true if each variable and value are the same, otherwise false.
    def eql?(other)
      return false if (other.nil? or self.class != other.class)
      ova = other.instance_variables
      iv = instance_variables
      return false if ova.size != iv.size
      iv.each do |vid|
        return false if instance_variable_get(vid) != other.instance_variable_get(vid)
      end
      true
    end
    alias == eql?
    
    # Define a new class based on the Ox::Bag class. This is used internally in
    # the Ox module and is available to service wrappers that receive XML
    # requests that include Objects of Classes not defined in the storage
    # process.
    # - +classname+ (String) Class name or symbol that includes Module names.
    # *return* [Object] an instance of the specified Class.
    #
    # _raise_ [NameError] if the classname is invalid.
    def self.define_class(classname)
      classname = classname.to_s unless classname.is_a?(String)
      tokens = classname.split('::').map { |n| n.to_sym }
      raise NameError.new("Invalid classname '#{classname}") if tokens.empty?
      m = Object
      tokens[0..-2].each do |sym|
        if m.const_defined?(sym)
          m = m.const_get(sym)
        else
          c = Module.new
          m.const_set(sym, c)
          m = c
        end
      end
      sym = tokens[-1]
      if m.const_defined?(sym)
        c = m.const_get(sym)
      else
        c = Class.new(Ox::Bag)
        m.const_set(sym, c)
      end
      c
    end

  end # Bag
end # Ox
