module RDF
  ##
  module Durable
    extend RDF::Util::Aliasing::LateBound

    ##
    # Returns `true` if `self` is durable.
    #
    # @return [Boolean]
    # @see    #nondurable?
    def durable?
      true
    end

    alias_method :persistent?, :durable?

    ##
    # Returns `true` if `self` is nondurable.
    #
    # @return [Boolean]
    # @see    #durable?
    def nondurable?
      !durable?
    end

    alias_method :ephemeral?,     :nondurable?
    alias_method :nonpersistent?, :nondurable?
    alias_method :transient?,     :nondurable?
    alias_method :volatile?,      :nondurable?
  end
end
