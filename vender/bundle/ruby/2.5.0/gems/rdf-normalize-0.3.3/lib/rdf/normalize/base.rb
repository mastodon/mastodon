module RDF::Normalize
  ##
  # Abstract class for pluggable normalization algorithms. Delegates to a default or selected algorithm if instantiated
  module Base
    attr_reader :dataset

    # Enumerates normalized statements
    #
    # @yield statement
    # @yieldparam [RDF::Statement] statement
    def each(&block)
      raise "Not Implemented"
    end
  end
end