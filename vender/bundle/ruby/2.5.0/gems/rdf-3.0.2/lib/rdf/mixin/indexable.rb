module RDF
  ##
  # A mixin that can be used to mark RDF repository implementations as
  # indexable.
  #
  # @since 0.3.0
  module Indexable
    ##
    # Returns `true` if `self` is indexed at present.
    #
    # @abstract
    # @return [Boolean]
    def indexed?
      false
    end

    ##
    # Indexes `self`.
    #
    # @abstract
    # @return [self]
    def index!
      raise NotImplementedError, "#{self.class}#index!"
    end
  end # Indexable
end # RDF
