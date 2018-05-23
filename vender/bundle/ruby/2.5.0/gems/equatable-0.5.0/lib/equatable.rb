# encoding: utf-8

require 'equatable/version'

# Make it easy to define equality and hash methods.
module Equatable
  # Hook into module inclusion.
  #
  # @param [Module] base
  #   the module or class including Equatable
  #
  # @return [self]
  #
  # @api private
  def self.included(base)
    super
    base.extend(self)
    base.class_eval do
      include Methods
      define_methods
    end
  end

  # Holds all attributes used for comparison.
  #
  # @return [Array<Symbol>]
  #
  # @api private
  attr_reader :comparison_attrs

  # Objects that include this module are assumed to be value objects.
  # It is also assumed that the only values that affect the results of
  # equality comparison are the values of the object's attributes.
  #
  # @param [Array<Symbol>] *args
  #
  # @return [undefined]
  #
  # @api public
  def attr_reader(*args)
    super
    comparison_attrs.concat(args)
  end

  # Copy the comparison_attrs into the subclass.
  #
  # @param [Class] subclass
  #
  # @api private
  def inherited(subclass)
    super
    subclass.instance_variable_set(:@comparison_attrs, comparison_attrs.dup)
  end

  private

  # Define all methods needed for ensuring object's equality.
  #
  # @return [undefined]
  #
  # @api private
  def define_methods
    define_comparison_attrs
    define_compare
    define_hash
    define_inspect
  end

  # Define class instance #comparison_attrs as an empty array.
  #
  # @return [undefined]
  #
  # @api private
  def define_comparison_attrs
    instance_variable_set('@comparison_attrs', [])
  end

  # Define a #compare? method to check if the receiver is the same
  # as the other object.
  #
  # @return [undefined]
  #
  # @api private
  def define_compare
    define_method(:compare?) do |comparator, other|
      klass = self.class
      attrs = klass.comparison_attrs
      attrs.all? do |attr|
        other.respond_to?(attr) && send(attr).send(comparator, other.send(attr))
      end
    end
  end

  # Define a hash method that ensures that the hash value is the same for
  # the same instance attributes and their corresponding values.
  #
  # @api private
  def define_hash
    define_method(:hash) do
      klass = self.class
      attrs = klass.comparison_attrs
      ([klass] + attrs.map { |attr| send(attr) }).hash
    end
  end

  # Define an inspect method that shows the class name and the values for the
  # instance's attributes.
  #
  # @return [undefined]
  #
  # @api private
  def define_inspect
    define_method(:inspect) do
      klass = self.class
      name  = klass.name || klass.inspect
      attrs = klass.comparison_attrs
      "#<#{name}#{attrs.map { |attr| " #{attr}=#{send(attr).inspect}" }.join}>"
    end
  end

  # The equality methods
  module Methods
    # Compare two objects for equality based on their value
    # and being an instance of the given class.
    #
    # @param [Object] other
    #   the other object in comparison
    #
    # @return [Boolean]
    #
    # @api public
    def eql?(other)
      instance_of?(other.class) && compare?(__method__, other)
    end

    # Compare two objects for equality based on their value
    # and being a subclass of the given class.
    #
    # @param [Object] other
    #   the other object in comparison
    #
    # @return [Boolean]
    #
    # @api public
    def ==(other)
      other.is_a?(self.class) && compare?(__method__, other)
    end
  end # Methods
end # Equatable
