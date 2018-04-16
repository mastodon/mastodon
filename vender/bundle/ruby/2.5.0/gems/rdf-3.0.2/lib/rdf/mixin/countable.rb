module RDF
  ##
  # @since 0.2.0
  module Countable
    autoload :Enumerator, 'rdf/mixin/enumerator'
    extend RDF::Util::Aliasing::LateBound

    ##
    # Returns `true` if `self` contains no RDF statements.
    #
    # @return [Boolean]
    def empty?
      each {return false}
      true
    end

    ##
    # Returns the number of RDF statements in `self`.
    #
    # @return [Integer]
    def count
      count = 0
      each { count += 1 }
      count
    end
    alias_method :size, :count

    ##
    # @private
    # @param  [Symbol, #to_sym] method
    # @return [Enumerator]
    # @see    Object#enum_for
    def enum_for(method = :each, *args)
      # Ensure that enumerators support the `#empty?` and `#count` methods:
      this = self
      Countable::Enumerator.new do |yielder|
        this.send(method, *args) {|y| yielder << y}
      end
    end
    alias_method :to_enum, :enum_for
  end # Countable
end # RDF
