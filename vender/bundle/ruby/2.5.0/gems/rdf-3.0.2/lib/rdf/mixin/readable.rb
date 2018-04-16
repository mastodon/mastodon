module RDF
  ##
  module Readable
    extend RDF::Util::Aliasing::LateBound

    ##
    # Returns `true` if `self` is readable.
    #
    # @return [Boolean]
    # @see    RDF::Writable#writable?
    def readable?
      true
    end
  end
end
