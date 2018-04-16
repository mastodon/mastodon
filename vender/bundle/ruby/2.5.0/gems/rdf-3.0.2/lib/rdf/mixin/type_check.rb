module RDF
  ##
  # An RDF type check mixin.
  #
  # This module implements #type_error, which will raise TypeError.
  #
  # @see RDF::Value
  # @see RDF::Literal
  # @see RDF::Literal
  module TypeCheck
    ##
    # Default implementation of type_error, which returns false.
    # Classes including RDF::TypeCheck will raise TypeError
    # instead.
    #
    # @raise [TypeError]
    def type_error(message)
      raise TypeError, message
    end
  end # TypeCheck
end # RDF
