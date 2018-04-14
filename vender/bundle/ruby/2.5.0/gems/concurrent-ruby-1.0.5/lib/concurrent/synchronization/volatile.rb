module Concurrent
  module Synchronization

    # Volatile adds the attr_volatile class method when included.
    #
    # @example
    #   class Foo
    #     include Concurrent::Synchronization::Volatile
    #
    #     attr_volatile :bar
    #
    #     def initialize
    #       self.bar = 1
    #     end
    #   end
    #
    #  foo = Foo.new
    #  foo.bar
    #  => 1
    #  foo.bar = 2
    #  => 2

    Volatile = case
    when Concurrent.on_cruby?
      MriAttrVolatile
    when Concurrent.on_jruby?
      JRubyAttrVolatile
    when Concurrent.on_rbx? || Concurrent.on_truffle?
      RbxAttrVolatile
    else
      MriAttrVolatile
    end
  end
end
