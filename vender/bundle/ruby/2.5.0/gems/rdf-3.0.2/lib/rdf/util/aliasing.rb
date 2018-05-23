module RDF; module Util
  module Aliasing
    ##
    # Helpers for late-bound instance method aliasing.
    #
    # Anything that extends this module will obtain an `alias_method` class
    # method that creates late-bound instance method aliases instead of the
    # default early-bound aliases created by Ruby's `Module#alias_method`.
    #
    # This is useful because RDF.rb mixins typically alias a number of
    # overridable methods. For example, `RDF::Enumerable#count` has the
    # aliases `#size` and `#length`. Normally if implementing classes were
    # to override the default method, the aliased methods would still be
    # bound to the mixin's original reference implementation rather than the
    # new overridden method. Mixing in this module into the implementing
    # class fixes this problem.
    #
    # @example Using late-bound aliasing in a module
    #   module MyModule
    #     extend RDF::Util::Aliasing::LateBound
    #   end
    #
    # @example Using late-bound aliasing in a class
    #   class MyClass
    #     extend RDF::Util::Aliasing::LateBound
    #   end
    #
    # @see   http://en.wikipedia.org/wiki/Name_binding
    # @since 0.2.0
    module LateBound
      ##
      # Makes `new_name` a late-bound alias of the method `old_name`.
      #
      # @example Aliasing the `#count` method to `#size` and `#length`
      #   alias_method :size,   :count
      #   alias_method :length, :count
      #
      # @param  [Symbol, #to_sym] new_name
      # @param  [Symbol, #to_sym] old_name
      # @return [void]
      # @see    http://ruby-doc.org/core/classes/Module.html#M001653
      def alias_method(new_name, old_name)
        new_name, old_name = new_name.to_sym, old_name.to_sym

        self.__send__(:define_method, new_name) do |*args, &block|
          __send__(old_name, *args, &block)
        end

        return self
      end
    end # LateBound
  end # Aliasing
end; end # RDF::Util
